
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/foodanalysis_model.dart';

class VisionAIService {
  Future<String> detectFoodName(File imageFile) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "temperature": 0.1,
        "messages": [
          {
            "role": "system",
            "content": "You identify food from images. Return ONLY JSON."
          },
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": """
Identify the main visible food in the image.

Return ONLY JSON:
{
  "food": ""
}
"""
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/jpeg;base64,$base64Image"
                }
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Vision API error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final content = data["choices"][0]["message"]["content"];

    final cleaned = content
        .replaceAll("```json", "")
        .replaceAll("```", "")
        .trim();

    final jsonData = jsonDecode(cleaned);

    return jsonData["food"] ?? "Unknown Food";
  }

Future<FoodAnalysis> calculateMacrosFromDescription({
  required String foodDescription,
}) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'];

  final response = await http.post(
    Uri.parse("https://api.openai.com/v1/chat/completions"),
    headers: {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "model": "gpt-4o-mini",
      "temperature": 0.1,
      "messages": [
        {
          "role": "system",
          "content": """
You are a nutrition expert.
Calculate total calories and macros based on the exact food description provided by the user.
Return ONLY valid JSON.
No markdown.
No explanation.
"""
        },
        {
          "role": "user",
          "content": """
Food description:
$foodDescription

Calculate total nutrition for the full described meal.

Return ONLY JSON:
{
  "food": "$foodDescription",
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
"""
        }
      ],
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Macro API error: ${response.body}");
  }

  final data = jsonDecode(response.body);
  final content = data["choices"][0]["message"]["content"];

  final cleaned = content
      .replaceAll("```json", "")
      .replaceAll("```", "")
      .trim();

  final jsonData = jsonDecode(cleaned);

  return FoodAnalysis.fromJson(jsonData);
}


  Future<FoodAnalysis> calculateMacros({
    required String food,
    required int quantity,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "temperature": 0.1,
        "messages": [
          {
            "role": "system",
            "content": """
You are a nutrition expert.
Calculate nutrition based on food name and exact user-provided quantity.
Return ONLY valid JSON.
No markdown.
No explanation.
"""
          },
          {
            "role": "user",
            "content": """
Food: $food
Quantity: $quantity grams

Calculate nutrition for exactly $quantity grams.

Return ONLY JSON:
{
  "food": "$food",
  "quantity": $quantity,
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fats": 0,
  "fiber": 0,
  "health_score": 0,
  "advice": "",
  "alternative_food": ""
}
"""
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Macro API error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final content = data["choices"][0]["message"]["content"];

    final cleaned = content
        .replaceAll("```json", "")
        .replaceAll("```", "")
        .trim();

    final jsonData = jsonDecode(cleaned);

    return FoodAnalysis.fromJson(jsonData);
  }
}