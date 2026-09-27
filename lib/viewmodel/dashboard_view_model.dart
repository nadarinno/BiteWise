

import 'package:flutter/material.dart';

import '../model/dailyplan_model.dart';
import '../services/user_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final UserService _service = UserService();

  List<int> weeklyCalories = List<int>.filled(7, 0);

  int todayCalories = 0;
  int goalCalories = 2000;

  int todayProtein = 0;
  int todayCarbs = 0;
  int todayFats = 0;
  int todayFiber = 0;

  int proteinGoal = 0;
  int carbsGoal = 0;
  int fatsGoal = 0;
  int fiberGoal = 0;

  DailyPlan? todayPlan;

  String userName = "";
  bool isLoading = false;

  DateTime selectedWeekStart = _getStartOfWeek(DateTime.now());

  static DateTime _getStartOfWeek(DateTime date) {
    final cleanDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return cleanDate.subtract(
      Duration(days: cleanDate.weekday - 1),
    );
  }

  double get progress {
    if (goalCalories <= 0) return 0;

    return (todayCalories / goalCalories).clamp(0.0, 1.0);
  }

  int get remainingCalories {
    final remaining = goalCalories - todayCalories;

    return remaining < 0 ? 0 : remaining;
  }

  bool get isCurrentWeek {
    final currentWeekStart = _getStartOfWeek(DateTime.now());
    final selectedStart = _getStartOfWeek(selectedWeekStart);

    return selectedStart.year == currentWeekStart.year &&
        selectedStart.month == currentWeekStart.month &&
        selectedStart.day == currentWeekStart.day;
  }

  int get highlightedDayIndex {
    if (!isCurrentWeek) return -1;

    return DateTime.now().weekday - 1;
  }

  String get selectedWeekText {
    final weekEnd = selectedWeekStart.add(const Duration(days: 6));

    return "${selectedWeekStart.day}/${selectedWeekStart.month} - ${weekEnd.day}/${weekEnd.month}";
  }

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      selectedWeekStart = _getStartOfWeek(selectedWeekStart);

      final userData = await _service.getUserData();

      userName = userData["name"] ?? "";

      final results = await Future.wait<dynamic>([
        _service.getWeeklyCalories(weekStartDate: selectedWeekStart),
        _service.getTodayCalories(),
        _service.calculateGoalCalories(),
        _service.getTodayPlan(),
        _service.getTodayMeals(),
        _service.calculateMacroTargets(),
      ]);

      weeklyCalories = _normalizeWeeklyCalories(results[0]);
      todayCalories = _toInt(results[1]);
      goalCalories = _toInt(results[2]);
      todayPlan = results[3] as DailyPlan?;

      final todayMeals = results[4] as List<Map<String, dynamic>>;
      final macroTargets = results[5] as Map<String, int>;

      todayProtein = _sumMacro(todayMeals, "protein");
      todayCarbs = _sumMacro(todayMeals, "carbs");
      todayFats = _sumMacro(todayMeals, "fats");
      todayFiber = _sumMacro(todayMeals, "fiber");

      proteinGoal = macroTargets["proteinGoal"] ?? 0;
      carbsGoal = macroTargets["carbsGoal"] ?? 0;
      fatsGoal = macroTargets["fatsGoal"] ?? 0;
      fiberGoal = macroTargets["fiberGoal"] ?? 0;

      if (goalCalories <= 0) {
        goalCalories = 2000;
      }

      debugPrint("SELECTED WEEK: $selectedWeekText");
      debugPrint("WEEKLY CALORIES: $weeklyCalories");
      debugPrint("TODAY CALORIES: $todayCalories");
      debugPrint("TODAY PROTEIN: $todayProtein");
      debugPrint("TODAY CARBS: $todayCarbs");
      debugPrint("TODAY FATS: $todayFats");
      debugPrint("TODAY FIBER: $todayFiber");
      debugPrint("PROTEIN GOAL: $proteinGoal");
      debugPrint("CARBS GOAL: $carbsGoal");
      debugPrint("FATS GOAL: $fatsGoal");
      debugPrint("FIBER GOAL: $fiberGoal");
    } catch (e) {
      debugPrint("Dashboard loading error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAfterMealSaved() async {
    try {
      selectedWeekStart = _getStartOfWeek(selectedWeekStart);

      final results = await Future.wait<dynamic>([
        _service.getWeeklyCalories(weekStartDate: selectedWeekStart),
        _service.getTodayCalories(),
        _service.calculateGoalCalories(),
        _service.getTodayMeals(),
        _service.calculateMacroTargets(),
      ]);

      weeklyCalories = _normalizeWeeklyCalories(results[0]);
      todayCalories = _toInt(results[1]);
      goalCalories = _toInt(results[2]);

      final todayMeals = results[3] as List<Map<String, dynamic>>;
      final macroTargets = results[4] as Map<String, int>;

      todayProtein = _sumMacro(todayMeals, "protein");
      todayCarbs = _sumMacro(todayMeals, "carbs");
      todayFats = _sumMacro(todayMeals, "fats");
      todayFiber = _sumMacro(todayMeals, "fiber");

      proteinGoal = macroTargets["proteinGoal"] ?? 0;
      carbsGoal = macroTargets["carbsGoal"] ?? 0;
      fatsGoal = macroTargets["fatsGoal"] ?? 0;
      fiberGoal = macroTargets["fiberGoal"] ?? 0;

      if (goalCalories <= 0) {
        goalCalories = 2000;
      }

      debugPrint("REFRESH WEEK: $selectedWeekText");
      debugPrint("REFRESH WEEKLY: $weeklyCalories");
      debugPrint("REFRESH CALORIES: $todayCalories");
      debugPrint("REFRESH PROTEIN: $todayProtein");
      debugPrint("REFRESH CARBS: $todayCarbs");
      debugPrint("REFRESH FATS: $todayFats");
      debugPrint("REFRESH FIBER: $todayFiber");

      notifyListeners();
    } catch (e) {
      debugPrint("Dashboard refresh error: $e");
    }
  }

  Future<void> goToPreviousWeek() async {
    selectedWeekStart = _getStartOfWeek(
      selectedWeekStart.subtract(const Duration(days: 7)),
    );

    await loadDashboard();
  }

  Future<void> goToNextWeek() async {
    selectedWeekStart = _getStartOfWeek(
      selectedWeekStart.add(const Duration(days: 7)),
    );

    await loadDashboard();
  }

  Future<void> goToCurrentWeek() async {
    selectedWeekStart = _getStartOfWeek(DateTime.now());

    await loadDashboard();
  }

  List<int> _normalizeWeeklyCalories(dynamic value) {
    final result = List<int>.filled(7, 0);

    if (value is List) {
      for (int i = 0; i < value.length && i < 7; i++) {
        result[i] = _toInt(value[i]);
      }
    }

    return result;
  }

  int _sumMacro(List<Map<String, dynamic>> meals, String key) {
    return meals.fold<int>(
      0,
      (sum, meal) => sum + _toInt(meal[key]),
    );
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.round();

    if (value is num) return value.round();

    return int.tryParse(value.toString()) ?? 0;
  }
}