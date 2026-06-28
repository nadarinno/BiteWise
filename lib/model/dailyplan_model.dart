
class DailyPlan {
  final String breakfast;
  final String lunch;
  final String dinner;
  final String snack;

  final int breakfastCalories;
  final int lunchCalories;
  final int dinnerCalories;
  final int snackCalories;

  final int totalCalories;

  DailyPlan({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
    required this.breakfastCalories,
    required this.lunchCalories,
    required this.dinnerCalories,
    required this.snackCalories,
    required this.totalCalories,
  });

  Map<String, dynamic> toJson() {
    return {
      "breakfast": breakfast,
      "lunch": lunch,
      "dinner": dinner,
      "snack": snack,
      "breakfastCalories": breakfastCalories,
      "lunchCalories": lunchCalories,
      "dinnerCalories": dinnerCalories,
      "snackCalories": snackCalories,
      "totalCalories": totalCalories,
    };
  }

  factory DailyPlan.fromJson(Map<String, dynamic> map) {
    return DailyPlan(
      breakfast: map["breakfast"] ?? "",
      lunch: map["lunch"] ?? "",
      dinner: map["dinner"] ?? "",
      snack: map["snack"] ?? "",
      breakfastCalories: map["breakfastCalories"] ?? 0,
      lunchCalories: map["lunchCalories"] ?? 0,
      dinnerCalories: map["dinnerCalories"] ?? 0,
      snackCalories: map["snackCalories"] ?? 0,
      totalCalories: map["totalCalories"] ?? 0,
    );
  }
}