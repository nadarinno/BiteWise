
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LanguageViewModel extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadLanguageForCurrentUser() async {
    final uid = _uid;

    if (uid == null) {
      _locale = const Locale('en');
      notifyListeners();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      final data = doc.data();

      final savedLanguage = data?["language"] ?? "en";

      _locale = Locale(savedLanguage);
      notifyListeners();
    } catch (e) {
      _locale = const Locale('en');
      notifyListeners();
      debugPrint("LOAD LANGUAGE ERROR: $e");
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final uid = _uid;

    _locale = Locale(languageCode);
    notifyListeners();

    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(uid).set(
        {
          "language": languageCode,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint("SAVE LANGUAGE ERROR: $e");
    }
  }

  void resetToDefault() {
    _locale = const Locale('en');
    notifyListeners();
  }
}