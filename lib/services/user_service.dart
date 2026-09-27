import 'dart:io';
import 'package:bitewise/model/dailyplan_model.dart';
import 'package:bitewise/model/foodanalysis_model.dart';
import 'package:bitewise/model/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {

 // CREATE / UPDATE USER
Future<void> saveUser(UserModel user) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    throw Exception("User not logged in ❌");
  }

  final uid = currentUser.uid;

  await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .set({
    "uid": uid,
    "email": currentUser.email,
    "name": user.name,
    "age": user.age,
    "height": user.height,
    "weight": user.weight,
    "disease": user.disease,
    "goal": user.goal,
    "profileComplete": true,
    "updatedAt": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
 

  //  CHECK PROFILE 
  Future<bool> isProfileComplete() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .get();

  
  if (!doc.exists) return false;

  return doc.data()?["profileComplete"] == true;
}

  // UPDATE USER
  Future<void> updateUser(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set({
      ...data,
      "updatedAt": Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // PROFILE IMAGE
  Future<String> uploadProfileImage(File file) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child("users/$uid/profile.jpg");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  // GET USER
  Future<Map<String, dynamic>> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    return doc.data() ?? {};
  }


// SAVE MEAL
  Future<void> saveMealWithImage(
  FoodAnalysis meal,
  File imageFile, {
  required String mealType,
}) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final ref = FirebaseStorage.instance
      .ref()
      .child("users/$uid/meals/${DateTime.now().millisecondsSinceEpoch}.jpg");

  await ref.putFile(imageFile);

  final imageUrl = await ref.getDownloadURL();

  await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("meals")
      .add({
    ...meal.toJson(),
    "image": imageUrl,
    "mealType": mealType,
    "date": Timestamp.now(),
  });
}

  // TODAY CALORIES
  Future<int> getTodayCalories() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now();

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("meals")
        .get();

    int total = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data["date"] as Timestamp).toDate();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        total += (data["calories"] ?? 0) as int;
      }
    }

    return total;
  }

  // GOAL CALORIES
Future<int> calculateGoalCalories() async {
  final user = await getUserData();

  final ageRaw = user["age"];
  final weightRaw = user["weight"] ?? user["weightKg"];
  final heightRaw = user["height"] ?? user["heightCm"];
  final goal = user["goal"] ?? "maintain";
  final gender = user["gender"] ?? "female";
  final activityLevel = user["activityLevel"] ?? "sedentary";

  if (ageRaw == null || weightRaw == null || heightRaw == null) {
    throw Exception("User data incomplete");
  }

  final age = ageRaw is num
      ? ageRaw.toDouble()
      : double.tryParse(ageRaw.toString());

  final weight = weightRaw is num
      ? weightRaw.toDouble()
      : double.tryParse(weightRaw.toString());

  final height = heightRaw is num
      ? heightRaw.toDouble()
      : double.tryParse(heightRaw.toString());

  if (age == null || weight == null || height == null) {
    throw Exception("Invalid user data");
  }

  double bmr;

  if (gender == "male") {
    bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
  } else {
    bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
  }

  double activityFactor;

  if (activityLevel == "light") {
    activityFactor = 1.375;
  } else if (activityLevel == "moderate") {
    activityFactor = 1.55;
  } else if (activityLevel == "very_active") {
    activityFactor = 1.725;
  } else {
    activityFactor = 1.2;
  }

  final tdee = bmr * activityFactor;

  int targetCalories;

  if (goal == "lose") {
   
    targetCalories = (tdee * 0.80).round();
  } else if (goal == "gain") {

    targetCalories = (tdee * 1.15).round();
  } else {
    targetCalories = tdee.round();
  }

 
  if (gender == "male") {
    if (goal == "lose" && targetCalories < 1600) {
      targetCalories = 1600;
    }
  } else {
    if (goal == "lose" && targetCalories < 1300) {
      targetCalories = 1300;
    }
  }

  return targetCalories;
}


// Macros goal
Future<Map<String, int>> calculateMacroTargets() async {
  final rawCalories = await calculateGoalCalories();
  final userData = await getUserData();

  final goal = userData["goal"] ?? "maintain";
  final activity = userData["activityLevel"] ?? "moderate";

  final weightRaw = userData["weight"] ?? userData["weightKg"] ?? 70;
  final weight = weightRaw is num
      ? weightRaw.toDouble()
      : double.tryParse(weightRaw.toString()) ?? 70.0;

  int calories = rawCalories;


  if (goal == "lose" && calories < 1300) {
    calories = 1300;
  } else if (goal == "maintain" && calories < 1500) {
    calories = 1500;
  } else if (goal == "gain" && calories < 1700) {
    calories = 1700;
  }

  double proteinPerKg;
  double fatPercent;

  if (goal == "lose") {
    if (activity == "sedentary") {
      proteinPerKg = 1.6;
      fatPercent = 0.25;
    } else if (activity == "light") {
      proteinPerKg = 1.7;
      fatPercent = 0.25;
    } else if (activity == "moderate") {
      proteinPerKg = 1.8;
      fatPercent = 0.27;
    } else {
      proteinPerKg = 2.0;
      fatPercent = 0.27;
    }
  } else if (goal == "gain") {
    if (activity == "sedentary") {
      proteinPerKg = 1.6;
      fatPercent = 0.25;
    } else if (activity == "light") {
      proteinPerKg = 1.7;
      fatPercent = 0.25;
    } else if (activity == "moderate") {
      proteinPerKg = 1.8;
      fatPercent = 0.28;
    } else {
      proteinPerKg = 2.0;
      fatPercent = 0.28;
    }
  } else {
    if (activity == "sedentary") {
      proteinPerKg = 1.5;
      fatPercent = 0.25;
    } else if (activity == "light") {
      proteinPerKg = 1.6;
      fatPercent = 0.25;
    } else if (activity == "moderate") {
      proteinPerKg = 1.7;
      fatPercent = 0.27;
    } else {
      proteinPerKg = 1.8;
      fatPercent = 0.27;
    }
  }

  int proteinGoal = (weight * proteinPerKg).round();

  int fatsGoal = ((calories * fatPercent) / 9).round();

  final proteinCalories = proteinGoal * 4;
  final fatsCalories = fatsGoal * 9;

  int remainingCalories = calories - proteinCalories - fatsCalories;

  if (remainingCalories < 0) {
    remainingCalories = 0;
  }

  int carbsGoal = (remainingCalories / 4).round();

 
  int minCarbs;

  if (goal == "lose") {
    minCarbs = activity == "sedentary" ? 90 : 110;
  } else if (goal == "gain") {
    minCarbs = 180;
  } else {
    minCarbs = 130;
  }

  if (carbsGoal < minCarbs) {
    carbsGoal = minCarbs;

    final usedCalories = (proteinGoal * 4) + (carbsGoal * 4);
    final remainingForFats = calories - usedCalories;

    if (remainingForFats > 0) {
      fatsGoal = (remainingForFats / 9).round();
    } else {
      fatsGoal = (weight * 0.6).round();
    }
  }

  final fiberGoal = ((calories / 1000) * 14).round();

  return {
    "proteinGoal": proteinGoal,
    "carbsGoal": carbsGoal,
    "fatsGoal": fatsGoal,
    "fiberGoal": fiberGoal,
  };
}


  // SAVE PLAN
  Future<void> saveDailyPlan(DailyPlan plan) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final today = DateTime.now();
    final docId = "${today.year}-${today.month}-${today.day}";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("plans")
        .doc(docId)
        .set({
      ...plan.toJson(),
      "date": Timestamp.now(),
    });
  }

  // GET PLAN
  Future<DailyPlan?> getTodayPlan() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final today = DateTime.now();
    final docId = "${today.year}-${today.month}-${today.day}";

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("plans")
        .doc(docId)
        .get();

    if (!doc.exists) return null;

    return DailyPlan.fromJson(doc.data()!);
  }

 // WEEKLY CHART
Future<List<int>> getWeeklyCalories({DateTime? weekStartDate}) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final now = DateTime.now();

  final todayStart = DateTime(
    now.year,
    now.month,
    now.day,
  );

  final currentWeekStart = todayStart.subtract(
    Duration(days: todayStart.weekday - 1),
  );

  final selectedWeekStart = weekStartDate ?? currentWeekStart;

  final weekStart = DateTime(
    selectedWeekStart.year,
    selectedWeekStart.month,
    selectedWeekStart.day,
  );

  final weekEnd = weekStart.add(const Duration(days: 7));

  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("meals")
      .where(
        "date",
        isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
      )
      .where(
        "date",
        isLessThan: Timestamp.fromDate(weekEnd),
      )
      .orderBy("date")
      .get(const GetOptions(source: Source.server));

  final weekData = List<int>.filled(7, 0);

  for (final doc in snapshot.docs) {
    final data = doc.data();

    final timestamp = data["date"];

    if (timestamp == null || timestamp is! Timestamp) {
      continue;
    }

    final mealDate = timestamp.toDate();

    final index = mealDate.weekday - 1;

    if (index >= 0 && index < 7) {
      final caloriesValue = data["calories"] ?? 0;

      final calories = caloriesValue is int
          ? caloriesValue
          : int.tryParse(caloriesValue.toString()) ?? 0;

      weekData[index] += calories;
    }
  }

  return weekData;
}

Future<List<Map<String, dynamic>>> getTodayMeals() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    throw Exception("User not logged in");
  }

  final now = DateTime.now();

  final startOfDay = DateTime(
    now.year,
    now.month,
    now.day,
  );

  final endOfDay = startOfDay.add(const Duration(days: 1));

  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("meals")
      .where(
        "createdAt",
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
      )
      .where(
        "createdAt",
        isLessThan: Timestamp.fromDate(endOfDay),
      )
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}

}