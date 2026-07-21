import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_theme.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _themePaletteKey = 'theme_palette';
  static const String _timelineLayoutKey = 'timeline_layout';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _userNameKey = 'user_name';

  ThemeMode _themeMode = ThemeMode.system;
  String _themePalette = 'lilac';
  String _timelineLayout = 'playful';
  bool _onboardingCompleted = false;
  String _userName = 'Sarah';

  ThemeMode get themeMode => _themeMode;
  String get themePalette => _themePalette;
  String get timelineLayout => _timelineLayout;
  bool get onboardingCompleted => _onboardingCompleted;
  String get userName => _userName;

  ThemeService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMode = prefs.getString(_themeModeKey);
    if (savedMode != null) {
      _themeMode = ThemeModeOption.fromLabel(savedMode).mode;
    }

    _themePalette = prefs.getString(_themePaletteKey) ?? 'lilac';
    _timelineLayout = prefs.getString(_timelineLayoutKey) ?? 'playful';
    _onboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
    _userName = prefs.getString(_userNameKey) ?? 'Sarah';

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, ThemeModeOption.fromMode(mode).label);
  }

  Future<void> setThemePalette(String palette) async {
    if (_themePalette == palette) return;
    _themePalette = palette;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePaletteKey, palette);
  }

  Future<void> setTimelineLayout(String layout) async {
    if (_timelineLayout == layout) return;
    _timelineLayout = layout;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timelineLayoutKey, layout);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    if (_onboardingCompleted == completed) return;
    _onboardingCompleted = completed;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  Future<void> setUserName(String name) async {
    if (_userName == name) return;
    _userName = name;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }
}
