import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadThemeForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _isDark = true;
      notifyListeners();
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    _isDark = data?['isDarkMode'] ?? true;

    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDark = isDark;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'isDarkMode': isDark,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> toggleTheme() async {
    await setTheme(!_isDark);
  }

  void resetToDefaultDark() {
    _isDark = true;
    notifyListeners();
  }
}