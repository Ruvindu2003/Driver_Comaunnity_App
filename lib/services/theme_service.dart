import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF667eea),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF667eea),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1a1a1a),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1a1a1a),
        selectedItemColor: Color(0xFF667eea),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}
