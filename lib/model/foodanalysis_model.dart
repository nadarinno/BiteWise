
class FoodAnalysis {
  final String food;
  final int quantity;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final int fiber;
  final int healthScore;
  final String advice;
  final String alternative;

  FoodAnalysis({
    required this.food,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.healthScore,
    required this.advice,
    required this.alternative,
  });

  factory FoodAnalysis.fromJson(Map<String, dynamic> json) {
    return FoodAnalysis(
      food: json["food"] ?? "Unknown Food",
      quantity: (json["quantity"] ?? 100).toInt(),
      calories: (json["calories"] ?? 0).toInt(),
      protein: (json["protein"] ?? 0).toInt(),
      carbs: (json["carbs"] ?? 0).toInt(),
      fats: (json["fats"] ?? 0).toInt(),
      fiber: (json["fiber"] ?? 0).toInt(),
      healthScore: (json["health_score"] ?? 0).toInt(),
      advice: json["advice"] ?? "",
      alternative: json["alternative_food"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "food": food,
      "quantity": quantity,
      "calories": calories,
      "protein": protein,
      "carbs": carbs,
      "fats": fats,
      "fiber": fiber,
      "health_score": healthScore,
      "advice": advice,
      "alternative_food": alternative,
    };
  }
}