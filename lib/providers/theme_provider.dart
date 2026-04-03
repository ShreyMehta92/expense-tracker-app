import 'package:flutter/material.dart';
import '../services/hive_service.dart';

/// Provider for managing theme state (light/dark mode)
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Load saved theme preference
  void loadTheme() {
    _isDarkMode = HiveService.isDarkMode;
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await HiveService.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}
