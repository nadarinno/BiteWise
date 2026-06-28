
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../model/dailyplan_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final UserService _service = UserService();

  List<int> weeklyCalories = List<int>.filled(7, 0);
  int todayCalories = 0;
  int goalCalories = 2000;
  DailyPlan? todayPlan;

  String userName = "";

  bool isLoading = false;

  double get progress {
    if (goalCalories <= 0) return 0;
    return (todayCalories / goalCalories).clamp(0.0, 1.0);
  }

  int get remainingCalories {
    final remaining = goalCalories - todayCalories;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      final userData = await _service.getUserData();

      userName = userData["name"] ?? "";

      final results = await Future.wait([
        _service.getWeeklyCalories(),
        _service.getTodayCalories(),
        _service.calculateGoalCalories(),
        _service.getTodayPlan(),
      ]);

      weeklyCalories = results[0] as List<int>;
      todayCalories = results[1] as int;
      goalCalories = results[2] as int;
      todayPlan = results[3] as DailyPlan?;

      if (weeklyCalories.isEmpty) {
        weeklyCalories = List<int>.filled(7, 0);
      }

      if (goalCalories <= 0) {
        goalCalories = 2000;
      }
    } catch (e) {
      debugPrint("Dashboard loading error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

Future<void> refreshAfterMealSaved() async {
  try {
    todayCalories = await _service.getTodayCalories();
    weeklyCalories = List<int>.from(await _service.getWeeklyCalories());
    goalCalories = await _service.calculateGoalCalories();

    if (goalCalories <= 0) {
      goalCalories = 2000;
    }

    debugPrint("REFRESH TODAY: $todayCalories");
    debugPrint("REFRESH WEEKLY: $weeklyCalories");

    notifyListeners();
  } catch (e) {
    debugPrint("Dashboard refresh error: $e");
  }
}
}