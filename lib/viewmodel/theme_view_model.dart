import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _themeKey = "isDarkMode";

  bool _isDark = true;

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeViewModel() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _isDark = prefs.getBool(_themeKey) ?? true;

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDark);

    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDark = isDark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDark);

    notifyListeners();
  }
}