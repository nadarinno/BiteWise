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

  final age = user["age"];
  final weight = user["weight"];
  final height = user["height"];
  final goal = user["goal"];
  final gender = user["gender"] ?? "female";
  final activityLevel = user["activityLevel"] ?? "sedentary";

  if (age == null || weight == null || height == null || goal == null) {
    throw Exception("User data incomplete");
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

  double tdee = bmr * activityFactor;

  if (goal == "lose") return (tdee - 500).round();
  if (goal == "gain") return (tdee + 500).round();

  return tdee.round();
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
  Future<List<int>> getWeeklyCalories() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final now = DateTime.now();

  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = todayStart.subtract(const Duration(days: 6));
  final weekEnd = todayStart.add(const Duration(days: 1));

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
      .get(const GetOptions(source: Source.server));

  final weekData = List<int>.filled(7, 0);

  for (final doc in snapshot.docs) {
    final data = doc.data();

    final timestamp = data["date"];
    if (timestamp == null || timestamp is! Timestamp) continue;

    final mealDate = timestamp.toDate();
    final mealDay = DateTime(mealDate.year, mealDate.month, mealDate.day);

    final index = mealDay.difference(weekStart).inDays;

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
}