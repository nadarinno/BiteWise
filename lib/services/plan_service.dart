
import 'dart:convert';
import 'package:bitewise/model/dailyplan_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlanService {
  Future<DailyPlan> generatePlan({
    required int calories,
    required String goal,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    final breakfastCalories = (calories * 0.25).round();
    final lunchCalories = (calories * 0.35).round();
    final dinnerCalories = (calories * 0.30).round();
    final snackCalories =
        calories - breakfastCalories - lunchCalories - dinnerCalories;

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": """
Create a daily meal plan.

Goal: $goal
Total calories must be exactly: $calories kcal.

Meal calories must be exactly:
Breakfast: $breakfastCalories kcal
Lunch: $lunchCalories kcal
Dinner: $dinnerCalories kcal
Snack: $snackCalories kcal

Return ONLY valid JSON. No markdown. No explanation.

{
  "breakfast": "meal description",
  "lunch": "meal description",
  "dinner": "meal description",
  "snack": "meal description",
  "breakfastCalories": $breakfastCalories,
  "lunchCalories": $lunchCalories,
  "dinnerCalories": $dinnerCalories,
  "snackCalories": $snackCalories,
  "totalCalories": $calories
}
"""
          }
        ],
      }),
    );

    final data = jsonDecode(response.body);

    final content = data["choices"][0]["message"]["content"];

    final cleanedContent = content
        .replaceAll("```json", "")
        .replaceAll("```", "")
        .trim();

    final jsonData = jsonDecode(cleanedContent);

    return DailyPlan(
  breakfast: jsonData["breakfast"],
  lunch: jsonData["lunch"],
  dinner: jsonData["dinner"],
  snack: jsonData["snack"],
  breakfastCalories: breakfastCalories,
  lunchCalories: lunchCalories,
  dinnerCalories: dinnerCalories,
  snackCalories: snackCalories,
  totalCalories: calories,
);
  }
}