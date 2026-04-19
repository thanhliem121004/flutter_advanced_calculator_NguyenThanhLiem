import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/calculation_history.dart';
import '../models/calculator_settings.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<CalculationHistory>> loadHistory() async {
    final String? data = _prefs.getString(StorageKeys.history);
    if (data == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList
          .map((item) => CalculationHistory.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(List<CalculationHistory> history) async {
    final jsonList = history.map((h) => h.toJson()).toList();
    await _prefs.setString(StorageKeys.history, jsonEncode(jsonList));
  }

  Future<void> clearHistory() async {
    await _prefs.remove(StorageKeys.history);
  }

  Future<CalculatorSettings> loadSettings() async {
    final String? data = _prefs.getString(StorageKeys.settings);
    if (data == null) return const CalculatorSettings();

    try {
      final Map<String, dynamic> json =
          jsonDecode(data) as Map<String, dynamic>;
      return CalculatorSettings.fromJson(json);
    } catch (_) {
      return const CalculatorSettings();
    }
  }

  Future<void> saveSettings(CalculatorSettings settings) async {
    await _prefs.setString(StorageKeys.settings, jsonEncode(settings.toJson()));
  }

  Future<String> loadMemory() async {
    return _prefs.getString(StorageKeys.memory) ?? '0';
  }

  Future<void> saveMemory(String memory) async {
    await _prefs.setString(StorageKeys.memory, memory);
  }
}
