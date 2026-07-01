
import 'dart:convert';

import 'package:bitewise/model/dailyplan_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PlanService {
  Future<DailyPlan> generatePlan({
    required int calories,
    required String goal,
    String languageCode = "en",
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    final breakfastCalories = (calories * 0.25).round();
    final lunchCalories = (calories * 0.35).round();
    final dinnerCalories = (calories * 0.30).round();
    final snackCalories =
        calories - breakfastCalories - lunchCalories - dinnerCalories;

    final languageText = languageCode == "ar"
        ? """
The app language is Arabic.
Write breakfast, lunch, dinner, and snack descriptions in Arabic.
Keep JSON keys in English exactly.
Do not translate JSON keys.
"""
        : """
The app language is English.
Write breakfast, lunch, dinner, and snack descriptions in English.
Keep JSON keys in English exactly.
""";

    final quantityText = languageCode == "ar"
        ? """
Each meal description must include exact quantities for every ingredient.
Use Arabic meal descriptions.
Use measurable units like: غ، مل، كوب، ملعقة كبيرة، ملعقة صغيرة، قطعة.

Good Arabic examples:
- 2 بيض مسلوق، 60غ خبز أسمر، 100غ خضار، 10غ زيت زيتون
- 150غ صدر دجاج مشوي، 120غ أرز مطبوخ، 150غ سلطة، 15غ زيت زيتون
- 200غ لبن يوناني، 30غ شوفان، 100غ موز، 10غ عسل

Do not use vague words like:
قليل، كمية مناسبة، بعض، طبق، حصة.
"""
        : """
Each meal description must include exact quantities for every ingredient.
Use English meal descriptions.
Use measurable units like: g, ml, cup, tablespoon, teaspoon, piece.

Good English examples:
- 2 boiled eggs, 60g whole wheat bread, 100g vegetables, 10g olive oil
- 150g grilled chicken breast, 120g cooked rice, 150g salad, 15g olive oil
- 200g Greek yogurt, 30g oats, 100g banana, 10g honey

Do not use vague words like:
some, a little, suitable amount, serving, portion, plate.
""";

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "temperature": 0.2,
        "response_format": {
          "type": "json_object",
        },
        "messages": [
          {
            "role": "system",
            "content": """
You are a professional nutrition meal planner.
Create a realistic daily meal plan.

$languageText

$quantityText

Goal: $goal
Total calories must be exactly: $calories kcal.

Meal calories must be exactly:
Breakfast: $breakfastCalories kcal
Lunch: $lunchCalories kcal
Dinner: $dinnerCalories kcal
Snack: $snackCalories kcal

Return ONLY valid JSON with these exact keys:
{
  "breakfast": "",
  "lunch": "",
  "dinner": "",
  "snack": "",
  "breakfastCalories": $breakfastCalories,
  "lunchCalories": $lunchCalories,
  "dinnerCalories": $dinnerCalories,
  "snackCalories": $snackCalories,
  "totalCalories": $calories
}

Important:
- Keep JSON keys exactly in English.
- Do not translate JSON keys.
- Only translate breakfast, lunch, dinner, and snack values based on app language.
- Every meal description must include exact quantities.
- Calories must stay numbers.
- Do not return anything outside JSON.
"""
          }
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("PLAN API ERROR: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final content = data["choices"][0]["message"]["content"];

    final cleanedContent = content
        .replaceAll("```json", "")
        .replaceAll("```", "")
        .trim();

    final jsonData = jsonDecode(cleanedContent);

    return DailyPlan(
      breakfast: jsonData["breakfast"] ?? "",
      lunch: jsonData["lunch"] ?? "",
      dinner: jsonData["dinner"] ?? "",
      snack: jsonData["snack"] ?? "",
      breakfastCalories: breakfastCalories,
      lunchCalories: lunchCalories,
      dinnerCalories: dinnerCalories,
      snackCalories: snackCalories,
      totalCalories: calories,
    );
  }
}