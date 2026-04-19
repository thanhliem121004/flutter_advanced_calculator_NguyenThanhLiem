import 'package:flutter/material.dart';
import '../models/calculator_settings.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  AppThemeMode _themeMode = AppThemeMode.dark;

  ThemeProvider(this._storageService);

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> loadTheme() async {
    final settings = await _storageService.loadSettings();
    _themeMode = settings.themeMode;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
  }
}
