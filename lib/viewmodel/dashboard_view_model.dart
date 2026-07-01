
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

  late DateTime selectedWeekStart;

  DashboardViewModel() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    selectedWeekStart = todayStart.subtract(
      Duration(days: todayStart.weekday - 1),
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
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final currentWeekStart = todayStart.subtract(
      Duration(days: todayStart.weekday - 1),
    );

    return selectedWeekStart.year == currentWeekStart.year &&
        selectedWeekStart.month == currentWeekStart.month &&
        selectedWeekStart.day == currentWeekStart.day;
  }

  int? get highlightedDayIndex {
    if (!isCurrentWeek) return null;
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
      final userData = await _service.getUserData();

      userName = userData["name"] ?? "";

      final results = await Future.wait([
        _service.getWeeklyCalories(weekStartDate: selectedWeekStart),
        _service.getTodayCalories(),
        _service.calculateGoalCalories(),
        _service.getTodayPlan(),
      ]);

      weeklyCalories = _normalizeWeeklyCalories(results[0]);
      todayCalories = results[1] as int;
      goalCalories = results[2] as int;
      todayPlan = results[3] as DailyPlan?;

      if (goalCalories <= 0) {
        goalCalories = 2000;
      }

      debugPrint("SELECTED WEEK: $selectedWeekText");
      debugPrint("WEEKLY CALORIES: $weeklyCalories");
    } catch (e) {
      debugPrint("Dashboard loading error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAfterMealSaved() async {
    try {
      todayCalories = await _service.getTodayCalories();

      weeklyCalories = _normalizeWeeklyCalories(
        await _service.getWeeklyCalories(
          weekStartDate: selectedWeekStart,
        ),
      );

      goalCalories = await _service.calculateGoalCalories();

      if (goalCalories <= 0) {
        goalCalories = 2000;
      }

      debugPrint("REFRESH WEEK: $selectedWeekText");
      debugPrint("REFRESH WEEKLY: $weeklyCalories");

      notifyListeners();
    } catch (e) {
      debugPrint("Dashboard refresh error: $e");
    }
  }

  Future<void> goToPreviousWeek() async {
    selectedWeekStart = selectedWeekStart.subtract(
      const Duration(days: 7),
    );

    await loadDashboard();
  }

  Future<void> goToNextWeek() async {
    selectedWeekStart = selectedWeekStart.add(
      const Duration(days: 7),
    );

    await loadDashboard();
  }

  Future<void> goToCurrentWeek() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    selectedWeekStart = todayStart.subtract(
      Duration(days: todayStart.weekday - 1),
    );

    await loadDashboard();
  }

  List<int> _normalizeWeeklyCalories(dynamic value) {
    final result = List<int>.filled(7, 0);

    if (value is List) {
      for (int i = 0; i < value.length && i < 7; i++) {
        final item = value[i];

        if (item is int) {
          result[i] = item;
        } else {
          result[i] = int.tryParse(item.toString()) ?? 0;
        }
      }
    }

    return result;
  }
}