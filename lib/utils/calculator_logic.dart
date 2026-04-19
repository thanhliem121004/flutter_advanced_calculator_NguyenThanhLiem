import 'dart:math' as math;

enum ButtonType {
  number,
  operator,
  function,
  equals,
  clear,
  memory,
  parenthesis,
  scientific,
}

class CalculatorLogic {
  String _expression = '';
  String _currentNumber = '0';
  String _displayExpression = '';
  String _memory = '0';
  bool _shouldResetInput = false;
  bool _isRadiansMode = false;
  int _precision = 10;
  double? _lastResult;
  bool _isSecondFunction = false;

  String get expression => _displayExpression;
  String get currentNumber => _currentNumber;
  String get memory => _memory;
  bool get shouldResetInput => _shouldResetInput;
  bool get isRadiansMode => _isRadiansMode;
  bool get hasMemory => _memory != '0';
  bool get isSecondFunction => _isSecondFunction;
  double? get lastResult => _lastResult;

  set radiansMode(bool value) => _isRadiansMode = value;
  set precision(int value) => _precision = value;

  void setMemory(String value) => _memory = value;

  void toggleSecondFunction() {
    _isSecondFunction = !_isSecondFunction;
  }

  void clearAll() {
    _expression = '';
    _currentNumber = '0';
    _displayExpression = '';
    _shouldResetInput = false;
    _lastResult = null;
  }

  void clearEntry() {
    _currentNumber = '0';
    _displayExpression = _expression;
  }

  void setCurrentNumber(String value) {
    _currentNumber = value;
  }

  void setExpression(String value) {
    _expression = value;
  }

  void setShouldResetInput(bool value) {
    _shouldResetInput = value;
  }

  void setLastResult(double? value) {
    _lastResult = value;
  }

  void appendExpression(String value) {
    _expression += value;
  }

  String formatNumber(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(_precision);
  }

  double evaluateFactorial(int n) {
    if (n < 0) throw FormatException('Giai thừa không xác định cho số âm');
    if (n > 170) throw FormatException('Giai thừa quá lớn');
    if (n <= 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  double evaluateTrig(String func, double value) {
    double angle = _isRadiansMode ? value : value * math.pi / 180;
    switch (func) {
      case 'sin': return math.sin(angle);
      case 'cos': return math.cos(angle);
      case 'tan': return math.tan(angle);
      case 'asin': return _isRadiansMode ? math.asin(value) : math.asin(value) * 180 / math.pi;
      case 'acos': return _isRadiansMode ? math.acos(value) : math.acos(value) * 180 / math.pi;
      case 'atan': return _isRadiansMode ? math.atan(value) : math.atan(value) * 180 / math.pi;
      default: return value;
    }
  }

  double evaluateLog(String func, double value) {
    if (value <= 0) throw FormatException('Log không xác định cho giá trị không dương');
    switch (func) {
      case 'ln': return math.log(value);
      case 'log': return math.log(value) / math.ln10;
      default: return value;
    }
  }

  String formatResult(String result) {
    if (result == 'Lỗi' || result == 'Vô cực') return result;
    double? num = double.tryParse(result);
    if (num == null) return result;
    if (num == num.roundToDouble() && num.abs() < 1e15) {
      return num.toInt().toString();
    }
    String formatted = num.toStringAsFixed(_precision);
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    return formatted;
  }
}
