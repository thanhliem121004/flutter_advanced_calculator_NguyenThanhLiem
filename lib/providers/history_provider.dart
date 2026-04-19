import 'package:flutter/foundation.dart';
import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<CalculationHistory> _history = [];
  int _maxHistory = 50;

  HistoryProvider(this._storageService);

  List<CalculationHistory> get history => List.unmodifiable(_history);

  List<CalculationHistory> get recentHistory => _history.take(3).toList();

  Future<void> loadHistory() async {
    _history = await _storageService.loadHistory();
    notifyListeners();
  }

  Future<void> setMaxHistory(int max) async {
    _maxHistory = max;
    if (_history.length > max) {
      _history = _history.sublist(0, max);
    }
    notifyListeners();
  }

  int get maxHistory => _maxHistory;

  Future<void> addEntry(String expression, String result, CalculatorMode mode) async {
    if (expression.isEmpty || result == 'Lỗi') return;

    final entry = CalculationHistory(
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
      mode: mode.englishName,
    );

    _history.insert(0, entry);

    if (_history.length > _maxHistory) {
      _history = _history.sublist(0, _maxHistory);
    }

    await _storageService.saveHistory(_history);
    notifyListeners();
  }

  Future<void> removeEntry(int index) async {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      await _storageService.saveHistory(_history);
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _storageService.clearHistory();
    notifyListeners();
  }

  void useHistoryEntry(int index, void Function(String) onUse) {
    if (index >= 0 && index < _history.length) {
      onUse(_history[index].result);
    }
  }
}
