
import 'package:bitewise/model/user_model.dart';
import 'package:bitewise/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfileViewModel extends ChangeNotifier {

  bool isLoading = false;

Future<bool> saveProfile({
  required String name,
  required int age,
  required double height,
  required double weight,
  required String gender,
  required String activityLevel,
  required String disease,
  required String goal,
}) async {
  try {
    isLoading = true;
    notifyListeners();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    final user = UserModel(
      uid: currentUser.uid,
      name: name,
      age: age,
      height: height,
      weight: weight,
      gender: gender,
      activityLevel: activityLevel,
      disease: disease.isEmpty ? null : disease,
      goal: goal,
    );

    await UserService().saveUser(user);

    return true;
  } catch (e) {
    print("SAVE PROFILE ERROR: $e");
    return false;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
}