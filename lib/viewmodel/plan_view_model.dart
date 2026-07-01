
import 'package:flutter/material.dart';
import '../model/dailyplan_model.dart';
import '../services/plan_service.dart';
import '../services/user_service.dart';

class PlanViewModel extends ChangeNotifier {
  DailyPlan? plan;
  bool isLoading = false;
  String? error;

  final PlanService _planService = PlanService();
  final UserService _userService = UserService();

  Future<void> loadPlan({
  bool forceNew = false,
  String languageCode = "en",
}) async {
  try {
    isLoading = true;
    error = null;
    notifyListeners();

    if (!forceNew) {
      final savedPlan = await _userService.getTodayPlan();

      if (savedPlan != null) {
        plan = savedPlan;
        return;
      }
    }

    final calories = await _userService.calculateGoalCalories();
    final userData = await _userService.getUserData();
    final goal = userData["goal"] ?? "maintain";

    final newPlan = await _planService.generatePlan(
      calories: calories,
      goal: goal,
      languageCode: languageCode,
    );

    plan = newPlan;

    await _userService.saveDailyPlan(newPlan);
  } catch (e) {
    error = e.toString();
    print("PLAN ERROR: $e");
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
}