
import 'dart:io';

import 'package:bitewise/model/foodanalysis_model.dart';
import 'package:bitewise/services/user_service.dart';
import 'package:bitewise/services/visionai_service.dart';
import 'package:flutter/material.dart';

class NutritionViewModel extends ChangeNotifier {
  FoodAnalysis? result;
  bool isLoading = false;

  File? lastImage;
  String? selectedMealType;
  String? detectedFood;
  String? detectedDescription;
  String? errorMessage;

  final VisionAIService _service = VisionAIService();
  final UserService _userService = UserService();

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> analyzeImage(
    File file, {
    required String mealType,
    String languageCode = "en",
  }) async {
    try {
      _setLoading(true);

      errorMessage = null;
      lastImage = file;
      selectedMealType = mealType;

      final foodDetails = await _service.detectFoodDetails(
        file,
        languageCode: languageCode,
      );

      final isFood = foodDetails["is_food"] == true;
      final primaryFood = foodDetails["primary_food"]?.toString().trim() ?? "";
      final description = foodDetails["description"]?.toString().trim() ?? "";

      if (!isFood || primaryFood.isEmpty) {
        detectedFood = languageCode == "ar" ? "طعام غير معروف" : "Unknown Food";
        detectedDescription = "";

        result = FoodAnalysis(
          food: detectedFood!,
          quantity: 0,
          calories: 0,
          protein: 0,
          carbs: 0,
          fats: 0,
          fiber: 0,
          healthScore: 0,
          advice: languageCode == "ar"
              ? "الصورة لا تحتوي على طعام واضح. اكتبي تفاصيل الوجبة يدويًا لحساب السعرات."
              : "The image does not contain clear food. Enter the meal details manually to calculate calories.",
          alternative: "",
        );

        return;
      }

      detectedFood = primaryFood;
      detectedDescription = description;

      result = FoodAnalysis(
        food: detectedFood!,
        quantity: 0,
        calories: 0,
        protein: 0,
        carbs: 0,
        fats: 0,
        fiber: 0,
        healthScore: 0,
        advice: languageCode == "ar"
            ? "تم التعرف على الأكل من الصورة. أدخلي الكمية والتفاصيل لحساب السعرات بدقة."
            : "Food detected from the image. Enter quantity and details to calculate calories accurately.",
        alternative: "",
      );
    } catch (e) {
      errorMessage = e.toString();
      print("ANALYZE ERROR: $e");

      detectedFood = languageCode == "ar" ? "طعام غير معروف" : "Unknown Food";
      detectedDescription = "";

      result = FoodAnalysis(
        food: detectedFood!,
        quantity: 0,
        calories: 0,
        protein: 0,
        carbs: 0,
        fats: 0,
        fiber: 0,
        healthScore: 0,
        advice: languageCode == "ar"
            ? "صار خطأ أثناء التعرف على الطعام. اكتبي تفاصيل الوجبة يدويًا."
            : "An error occurred while detecting the food. Enter the meal details manually.",
        alternative: "",
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> calculateByMealDescription(
    String description, {
    String languageCode = "en",
  }) async {
    final cleanDescription = description.trim();

    if (cleanDescription.isEmpty) {
      throw Exception("Meal description is empty");
    }

    try {
      _setLoading(true);

      errorMessage = null;

      final newResult = await _service.calculateMacrosFromDescription(
        foodDescription: cleanDescription,
        languageCode: languageCode,
      );

      result = FoodAnalysis(
        food: detectedFood != null && detectedFood!.trim().isNotEmpty
            ? detectedFood!
            : newResult.food,
        quantity: newResult.quantity,
        calories: newResult.calories,
        protein: newResult.protein,
        carbs: newResult.carbs,
        fats: newResult.fats,
        fiber: newResult.fiber,
        healthScore: newResult.healthScore,
        advice: newResult.advice,
        alternative: newResult.alternative,
      );
    } catch (e) {
      errorMessage = e.toString();
      print("MACRO DESCRIPTION ERROR: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveMeal() async {
    if (result == null || lastImage == null || selectedMealType == null) {
      throw Exception("Missing meal data");
    }

    await _userService.saveMealWithImage(
      result!,
      lastImage!,
      mealType: selectedMealType!,
    );
  }
}