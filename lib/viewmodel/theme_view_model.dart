
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  bool get isDark => _isDarkMode;


  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadThemeForCurrentUser() async {
    final uid = _uid;

    if (uid == null) {
      _isDarkMode = true;
      notifyListeners();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      final data = doc.data();
      final savedTheme = data?["isDarkMode"];

      if (savedTheme is bool) {
        _isDarkMode = savedTheme;
      } else {
        _isDarkMode = true;

        await FirebaseFirestore.instance.collection("users").doc(uid).set(
          {
            "isDarkMode": true,
          },
          SetOptions(merge: true),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("LOAD THEME ERROR: $e");
      notifyListeners();
    }
  }

  Future<void> setTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    final uid = _uid;

    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(uid).set(
        {
          "isDarkMode": value,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint("SAVE THEME ERROR: $e");
    }
  }

  Future<void> toggleTheme() async {
    await setTheme(!_isDarkMode);
  }

  void resetToDefault() {
    _isDarkMode = true;
    notifyListeners();
  }
}