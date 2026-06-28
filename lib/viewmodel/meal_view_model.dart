import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MealViewModel extends ChangeNotifier {
  bool isLoading = false;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> deleteMeal(String docId) async {
    isLoading = true;
    notifyListeners();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("meals")
        .doc(docId)
        .delete();

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateCalories(String docId, int calories) async {
    isLoading = true;
    notifyListeners();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("meals")
        .doc(docId)
        .update({
      "calories": calories,
    });

    isLoading = false;
    notifyListeners();
  }
}