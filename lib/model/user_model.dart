class UserModel {
  final String uid;
  final String name;
  final int age;
  final double height;
  final double weight;
  final String gender;
  final String activityLevel;
  final String? disease;
  final String goal;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.activityLevel,
    this.disease,
    required this.goal,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "age": age,
      "height": height,
      "weight": weight,
      "gender": gender,
      "activityLevel": activityLevel,
      "disease": disease,
      "goal": goal,
    };
  }
}