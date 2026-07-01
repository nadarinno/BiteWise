

import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/foodanalysis_model.dart';

class VisionAIService {
  static const String _apiUrl = "https://api.openai.com/v1/chat/completions";


  static const String _visionModel = "gpt-4o";

  static const String _nutritionModel = "gpt-4o-mini";

  String _getApiKey() {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception("OPENAI_API_KEY is missing from .env file");
    }

    return apiKey;
  }

  String _languageInstruction(String languageCode) {
    if (languageCode == "ar") {
      return """
The app language is Arabic.
Write all user-facing text values in Arabic.
This includes: food, primary_food, all_foods, description, advice, and alternative_food.
Keep JSON keys in English exactly as requested.
Do not translate JSON keys.
Numbers must stay numbers, not strings.
""";
    }

    return """
The app language is English.
Write all user-facing text values in English.
Keep JSON keys in English exactly as requested.
Numbers must stay numbers, not strings.
""";
  }

  String _cleanJsonContent(String content) {
    return content
        .replaceAll("```json", "")
        .replaceAll("```", "")
        .trim();
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception("OpenAI API error: ${response.body}");
    }

    final data = jsonDecode(response.body);

    final content = data["choices"]?[0]?["message"]?["content"];

    if (content == null || content.toString().trim().isEmpty) {
      throw Exception("OpenAI API returned empty content");
    }

    final cleaned = _cleanJsonContent(content.toString());
    final decoded = jsonDecode(cleaned);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("OpenAI API returned invalid JSON object");
    }

    return decoded;
  }

  num _numValue(dynamic value, {num fallback = 0}) {
    if (value is num) return value;

    if (value is String) {
      return num.tryParse(value) ?? fallback;
    }

    return fallback;
  }

  String _stringValue(dynamic value, {String fallback = ""}) {
    if (value == null) return fallback;
    return value.toString();
  }

  Map<String, dynamic> _normalizeFoodAnalysisJson(
    Map<String, dynamic> jsonData, {
    required String languageCode,
  }) {
    return {
      "food": _stringValue(
        jsonData["food"],
        fallback: languageCode == "ar" ? "طعام غير معروف" : "Unknown Food",
      ),
      "quantity": _numValue(jsonData["quantity"]).round(),
      "calories": _numValue(jsonData["calories"]).round(),
      "protein": _numValue(jsonData["protein"]),
      "carbs": _numValue(jsonData["carbs"]),
      "fats": _numValue(jsonData["fats"]),
      "fiber": _numValue(jsonData["fiber"]),
      "health_score": _numValue(jsonData["health_score"]).round(),
      "advice": _stringValue(jsonData["advice"]),
      "alternative_food": _stringValue(jsonData["alternative_food"]),
    };
  }

  Future<Map<String, dynamic>> detectFoodDetails(
    File imageFile, {
    String languageCode = "en",
  }) async {
    final apiKey = _getApiKey();

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http
        .post(
          Uri.parse(_apiUrl),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "model": _visionModel,
            "temperature": 0.1,
            "response_format": {
              "type": "json_schema",
              "json_schema": {
                "name": "food_detection_result",
                "strict": true,
                "schema": {
                  "type": "object",
                  "additionalProperties": false,
                  "properties": {
                    "is_food": {
                      "type": "boolean",
                    },
                    "primary_food": {
                      "type": "string",
                    },
                    "all_foods": {
                      "type": "array",
                      "items": {
                        "type": "string",
                      },
                    },
                    "description": {
                      "type": "string",
                    },
                    "confidence": {
                      "type": "number",
                    },
                  },
                  "required": [
                    "is_food",
                    "primary_food",
                    "all_foods",
                    "description",
                    "confidence",
                  ],
                },
              },
            },
            "messages": [
              {
                "role": "system",
                "content": """
You are a highly accurate food recognition system.

Your job:
- Analyze the image carefully.
- Detect all clearly visible edible food items.
- Be specific, not generic.
- If the image contains a full meal, describe the full visible meal.
- If the image contains multiple items, mention every clearly visible item.
- Do not invent hidden ingredients.
- Do not guess ingredients that are not visible.
- Do not calculate calories here.
- If food is unclear, use the most likely broad food name.
- If there is no food in the image, set is_food to false.

${_languageInstruction(languageCode)}
""",
              },
              {
                "role": "user",
                "content": [
                  {
                    "type": "text",
                    "text": """
Identify the food in this image.

Return JSON with:
- is_food: true if the image contains food, otherwise false
- primary_food: the best complete name for the visible meal or main food
- all_foods: all clearly visible food items
- description: one detailed sentence describing the visible food
- confidence: a number from 0 to 1

Important:
If the app language is Arabic, write primary_food, all_foods, and description in Arabic.
Keep JSON keys in English.
""",
                  },
                  {
                    "type": "image_url",
                    "image_url": {
                      "url": "data:image/jpeg;base64,$base64Image",
                      "detail": "high",
                    },
                  },
                ],
              },
            ],
            "max_tokens": 500,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final jsonData = _decodeJsonResponse(response);

    final allFoodsRaw = jsonData["all_foods"];
    final allFoods = allFoodsRaw is List
        ? allFoodsRaw.map((item) => item.toString()).toList()
        : <String>[];

    return {
      "is_food": jsonData["is_food"] == true,
      "primary_food": _stringValue(jsonData["primary_food"]),
      "all_foods": allFoods,
      "description": _stringValue(jsonData["description"]),
      "confidence": _numValue(jsonData["confidence"]),
    };
  }

  Future<String> detectFoodName(
    File imageFile, {
    String languageCode = "en",
  }) async {
    final result = await detectFoodDetails(
      imageFile,
      languageCode: languageCode,
    );

    final isFood = result["is_food"] == true;
    final primaryFood = result["primary_food"]?.toString().trim() ?? "";

    if (!isFood || primaryFood.isEmpty) {
      return languageCode == "ar" ? "طعام غير معروف" : "Unknown Food";
    }

    return primaryFood;
  }

  Future<FoodAnalysis> calculateMacrosFromDescription({
    required String foodDescription,
    String languageCode = "en",
  }) async {
    final apiKey = _getApiKey();

    final response = await http
        .post(
          Uri.parse(_apiUrl),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "model": _nutritionModel,
            "temperature": 0.1,
            "response_format": {
              "type": "json_schema",
              "json_schema": {
                "name": "food_analysis_result",
                "strict": true,
                "schema": {
                  "type": "object",
                  "additionalProperties": false,
                  "properties": {
                    "food": {
                      "type": "string",
                    },
                    "quantity": {
                      "type": "number",
                    },
                    "calories": {
                      "type": "number",
                    },
                    "protein": {
                      "type": "number",
                    },
                    "carbs": {
                      "type": "number",
                    },
                    "fats": {
                      "type": "number",
                    },
                    "fiber": {
                      "type": "number",
                    },
                    "health_score": {
                      "type": "number",
                    },
                    "advice": {
                      "type": "string",
                    },
                    "alternative_food": {
                      "type": "string",
                    },
                  },
                  "required": [
                    "food",
                    "quantity",
                    "calories",
                    "protein",
                    "carbs",
                    "fats",
                    "fiber",
                    "health_score",
                    "advice",
                    "alternative_food",
                  ],
                },
              },
            },
            "messages": [
              {
                "role": "system",
                "content": """
You are a nutrition expert.

Calculate total calories and macros based on the exact food description provided by the user.

Rules:
- Return ONLY valid JSON.
- No markdown.
- No explanation.
- Estimate the full visible meal.
- Use realistic nutrition values.
- If the portion is not explicitly provided, estimate a normal serving size based on the description.
- quantity means estimated total meal weight in grams.
- health_score must be from 0 to 100.

${_languageInstruction(languageCode)}
""",
              },
              {
                "role": "user",
                "content": """
Food description:
$foodDescription

Calculate total nutrition for the full described meal.

Return JSON with these exact keys:
{
  "food": "",
  "quantity": 0,
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fats": 0,
  "fiber": 0,
  "health_score": 0,
  "advice": "",
  "alternative_food": ""
}

Important:
- Keep keys exactly in English.
- If the app language is Arabic, write food, advice, and alternative_food in Arabic.
- calories, protein, carbs, fats, fiber, quantity, and health_score must be numbers.
""",
              },
            ],
            "max_tokens": 500,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final jsonData = _decodeJsonResponse(response);

    final normalizedJson = _normalizeFoodAnalysisJson(
      jsonData,
      languageCode: languageCode,
    );

    return FoodAnalysis.fromJson(normalizedJson);
  }

  Future<FoodAnalysis> calculateMacros({
    required String food,
    required int quantity,
    String languageCode = "en",
  }) async {
    final apiKey = _getApiKey();

    final response = await http
        .post(
          Uri.parse(_apiUrl),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "model": _nutritionModel,
            "temperature": 0.1,
            "response_format": {
              "type": "json_schema",
              "json_schema": {
                "name": "food_analysis_result",
                "strict": true,
                "schema": {
                  "type": "object",
                  "additionalProperties": false,
                  "properties": {
                    "food": {
                      "type": "string",
                    },
                    "quantity": {
                      "type": "number",
                    },
                    "calories": {
                      "type": "number",
                    },
                    "protein": {
                      "type": "number",
                    },
                    "carbs": {
                      "type": "number",
                    },
                    "fats": {
                      "type": "number",
                    },
                    "fiber": {
                      "type": "number",
                    },
                    "health_score": {
                      "type": "number",
                    },
                    "advice": {
                      "type": "string",
                    },
                    "alternative_food": {
                      "type": "string",
                    },
                  },
                  "required": [
                    "food",
                    "quantity",
                    "calories",
                    "protein",
                    "carbs",
                    "fats",
                    "fiber",
                    "health_score",
                    "advice",
                    "alternative_food",
                  ],
                },
              },
            },
            "messages": [
              {
                "role": "system",
                "content": """
You are a nutrition expert.

Calculate nutrition based on food name and exact user-provided quantity.

Rules:
- Return ONLY valid JSON.
- No markdown.
- No explanation.
- quantity means grams.
- Calculate nutrition for exactly the quantity provided by the user.
- Use realistic nutrition values.
- health_score must be from 0 to 100.

${_languageInstruction(languageCode)}
""",
              },
              {
                "role": "user",
                "content": """
Food: $food
Quantity: $quantity grams

Calculate nutrition for exactly $quantity grams.

Return JSON with these exact keys:
{
  "food": "",
  "quantity": 0,
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fats": 0,
  "fiber": 0,
  "health_score": 0,
  "advice": "",
  "alternative_food": ""
}

Important:
- Keep keys exactly in English.
- If the app language is Arabic, write food, advice, and alternative_food in Arabic.
- calories, protein, carbs, fats, fiber, quantity, and health_score must be numbers.
""",
              },
            ],
            "max_tokens": 500,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final jsonData = _decodeJsonResponse(response);

    final normalizedJson = _normalizeFoodAnalysisJson(
      jsonData,
      languageCode: languageCode,
    );

    return FoodAnalysis.fromJson(normalizedJson);
  }

  Future<FoodAnalysis> analyzeImageDirectly({
    required File imageFile,
    String languageCode = "en",
  }) async {
    final foodDetails = await detectFoodDetails(
      imageFile,
      languageCode: languageCode,
    );

    final isFood = foodDetails["is_food"] == true;

    if (!isFood) {
      throw Exception(
        languageCode == "ar"
            ? "الصورة لا تحتوي على طعام واضح"
            : "The image does not contain clear food",
      );
    }

    final description = foodDetails["description"].toString();

    return calculateMacrosFromDescription(
      foodDescription: description,
      languageCode: languageCode,
    );
  }
}