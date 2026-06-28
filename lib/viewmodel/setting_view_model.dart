import 'dart:io';
import 'package:flutter/material.dart';
import '../services/user_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final UserService _service = UserService();

  bool isLoading = false;

  Future<Map<String, dynamic>> loadUser() async {
    return await _service.getUserData();
  }

  Future<void> updateProfileImage(File file) async {
    isLoading = true;
    notifyListeners();

    final url = await _service.uploadProfileImage(file);

    await _service.updateUser({
      "profileImage": url,
    });

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required double height,
    required double weight,
    required String disease,
    required String gender,
    required String activityLevel,
    required String goal,
  }) async {
    isLoading = true;
    notifyListeners();

    await _service.updateUser({
      "name": name,
      "age": age,
      "height": height,
      "weight": weight,
      "disease": disease.isEmpty ? null : disease,
      "gender": gender,
      "activityLevel": activityLevel,
      "goal": goal,
      "profileComplete": true,
    });

    isLoading = false;
    notifyListeners();
  }
}