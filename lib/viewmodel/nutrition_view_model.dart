
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

  final VisionAIService _service = VisionAIService();
  final UserService _userService = UserService();

  Future<void> analyzeImage(
    File file, {
    required String mealType,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      lastImage = file;
      selectedMealType = mealType;

      detectedFood = await _service.detectFoodName(file);

      result = FoodAnalysis(
        food: detectedFood ?? "Unknown Food",
        quantity: 0,
        calories: 0,
        protein: 0,
        carbs: 0,
        fats: 0,
        fiber: 0,
        healthScore: 0,
        advice: "",
        alternative: "",
      );
    } catch (e) {
      print("ANALYZE ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


Future<void> calculateByMealDescription(String description) async {
  if (description.trim().isEmpty) {
    throw Exception("Meal description is empty");
  }

  try {
    isLoading = true;
    notifyListeners();

   final oldFood = result!.food;

result = await _service.calculateMacrosFromDescription(
  foodDescription: description,
);


result = FoodAnalysis(
  food: oldFood,
  quantity: result!.quantity,
  calories: result!.calories,
  protein: result!.protein,
  carbs: result!.carbs,
  fats: result!.fats,
  fiber: result!.fiber,
  healthScore: result!.healthScore,
  advice: result!.advice,
  alternative: result!.alternative,
);
  } catch (e) {
    print("MACRO DESCRIPTION ERROR: $e");
  } finally {
    isLoading = false;
    notifyListeners();
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