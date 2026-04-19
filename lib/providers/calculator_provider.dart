import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:math_expressions/math_expressions.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../services/storage_service.dart';
import '../utils/calculator_logic.dart';

class CalculatorProvider extends ChangeNotifier {
  final StorageService _storageService;
  final CalculatorLogic _logic = CalculatorLogic();

  CalculatorMode _mode = CalculatorMode.basic;
  AngleMode _angleMode = AngleMode.degrees;
  int _precision = 10;
  String _display = '0';
  String _expression = '';
  String _memory = '0';
  bool _hasMemory = false;
  String? _errorMessage;
  bool _isSecondFunction = false;
  int _base = 10;
  String _programmerInput = '';
  int? _pendingBitwiseOp;
  int? _previousValue;
  String? _lastOperator;

  CalculatorProvider(this._storageService);

  CalculatorMode get mode => _mode;
  AngleMode get angleMode => _angleMode;
  int get precision => _precision;
  String get display => _display;
  String get expression => _expression;
  String get memory => _memory;
  bool get hasMemory => _hasMemory;
  String? get errorMessage => _errorMessage;
  bool get isSecondFunction => _isSecondFunction;
  int get base => _base;
  bool get isRadiansMode => _angleMode == AngleMode.radians;

  Future<void> loadSettings() async {
    final settings = await _storageService.loadSettings();
    _mode = settings.defaultMode;
    _angleMode = settings.angleMode;
    _precision = settings.decimalPrecision;
    _logic.precision = _precision;
    _logic.radiansMode = _angleMode == AngleMode.radians;
    _memory = await _storageService.loadMemory();
    _hasMemory = _memory != '0';
    _logic.setMemory(_memory);
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final settings = CalculatorSettings(
      defaultMode: _mode,
      angleMode: _angleMode,
      decimalPrecision: _precision,
    );
    await _storageService.saveSettings(settings);
  }

  void setMode(CalculatorMode newMode) {
    _mode = newMode;
    _display = '0';
    _expression = '';
    _errorMessage = null;
    _programmerInput = '';
    _pendingBitwiseOp = null;
    _previousValue = null;
    _lastOperator = null;
    notifyListeners();
  }

  void setAngleMode(AngleMode mode) {
    _angleMode = mode;
    _logic.radiansMode = mode == AngleMode.radians;
    notifyListeners();
  }

  void toggleAngleMode() {
    setAngleMode(_angleMode == AngleMode.degrees ? AngleMode.radians : AngleMode.degrees);
  }

  void setPrecision(int value) {
    _precision = value;
    _logic.precision = value;
    notifyListeners();
  }

  void toggleSecondFunction() {
    _isSecondFunction = !_isSecondFunction;
    notifyListeners();
  }

  void onButtonPressed(String value) {
    _errorMessage = null;

    if (_mode == CalculatorMode.programmer) {
      _handleProgrammerInput(value);
      return;
    }

    switch (value) {
      case 'C':
        _display = '0';
        _expression = '';
        _lastOperator = null;
        _logic.clearAll();
        break;
      case 'CE':
        _display = '0';
        _logic.clearEntry();
        break;
      case '⌫':
        _onBackspace();
        break;
      case '=':
        _onEquals();
        break;
      case '±':
        _onToggleSign();
        break;
      case '+':
      case '−':
      case '×':
      case '÷':
        _onOperator(value);
        break;
      case '%':
        _onPercentage();
        break;
      case '(':
      case ')':
        _onParenthesis(value);
        break;
      case '.':
        _onDecimal();
        break;
      case 'π':
      case 'Π':
        _onConstant(math.pi);
        break;
      case 'e':
        _onConstant(math.e);
        break;
      case 'sin':
      case 'cos':
      case 'tan':
        _onTrigFunction(value);
        break;
      case 'ln':
        _onLogFunction('ln');
        break;
      case 'log':
        _onLogFunction('log');
        break;
      case 'x²':
        _onPower(2);
        break;
      case 'x³':
        _onPower(3);
        break;
      case 'xʸ':
        _onOperator('^');
        break;
      case '√':
        _onSquareRoot();
        break;
      case '∛':
        _onCubeRoot();
        break;
      case '!':
        _onFactorial();
        break;
      case 'M+':
        _onMemoryAdd();
        break;
      case 'M-':
        _onMemorySubtract();
        break;
      case 'MR':
        _onMemoryRecall();
        break;
      case 'MC':
        _onMemoryClear();
        break;
      case '2nd':
        toggleSecondFunction();
        break;
      case 'DEG':
      case 'RAD':
        toggleAngleMode();
        break;
      default:
        if (RegExp(r'^[0-9]$').hasMatch(value)) {
          _onDigit(value);
        }
    }

    notifyListeners();
  }

  void _onDigit(String digit) {
    if (_display == '0') {
      _display = digit;
    } else if (_logic.shouldResetInput) {
      _display = digit;
      _logic.setShouldResetInput(false);
    } else {
      _display += digit;
    }
  }

  void _onBackspace() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
      if (_display == '-') _display = '0';
    } else {
      _display = '0';
    }
  }

  void _onEquals() {
    if (_expression.isEmpty) return;

    String fullExpr = _expression + _display;
    String result = _evaluate(fullExpr);

    _logic.setLastResult(double.tryParse(result));
    _display = result;
    _expression = '';
    _lastOperator = null;
    _logic.setShouldResetInput(true);
  }

  void _onToggleSign() {
    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else if (_display != '0') {
      _display = '-$_display';
    }
  }

  void _onOperator(String op) {
    String opReplace = op == '÷' ? '/' : (op == '×' ? '*' : op);

    if (_expression.isNotEmpty && _display == '0') {
      _expression = _expression.substring(0, _expression.length - 1) + opReplace;
      _lastOperator = op;
      _logic.setShouldResetInput(true);
      return;
    }

    if (_expression.isNotEmpty) {
      String exprToEval = _expression + _display;
      String result = _evaluate(exprToEval);
      if (result != 'Lỗi' && result != 'Vô cực') {
        _display = result;
        _logic.setLastResult(double.tryParse(result));
      }
    }

    _expression = _display + opReplace;
    _display = '0';
    _lastOperator = op;
    _logic.setShouldResetInput(true);
  }

  void _onPercentage() {
    try {
      double current = double.parse(_display);
      double? lastResult = _logic.lastResult;
      double pct = lastResult != null ? lastResult * current / 100 : current / 100;
      _display = _logic.formatResult(pct.toString());
    } catch (_) {}
  }

  void _onParenthesis(String paren) {
    _expression += paren;
  }

  void _onDecimal() {
    if (!_display.contains('.')) {
      _display = '$_display.';
    }
  }

  void _onConstant(double value) {
    _display = value == math.pi
        ? math.pi.toStringAsFixed(_precision)
        : math.e.toStringAsFixed(_precision);
    _logic.setShouldResetInput(true);
  }

  void _onTrigFunction(String func) {
    try {
      double value = double.parse(_display);
      double result = _logic.evaluateTrig(func, value);
      _display = _logic.formatResult(result.toString());
      _logic.setShouldResetInput(true);
    } catch (_) {
      _errorMessage = 'Lỗi';
    }
  }

  void _onLogFunction(String func) {
    try {
      double value = double.parse(_display);
      if (value <= 0) {
        _errorMessage = 'Lỗi: Giá trị phải dương';
        return;
      }
      double result = _logic.evaluateLog(func, value);
      _display = _logic.formatResult(result.toString());
      _logic.setShouldResetInput(true);
    } catch (_) {
      _errorMessage = 'Lỗi: Giá trị phải dương';
    }
  }

  void _onPower(int exponent) {
    try {
      double value = double.parse(_display);
      double result = math.pow(value, exponent).toDouble();
      _display = _logic.formatResult(result.toString());
      _logic.setShouldResetInput(true);
    } catch (_) {
      _errorMessage = 'Lỗi';
    }
  }

  void _onSquareRoot() {
    try {
      double value = double.parse(_display);
      if (value < 0) {
        _errorMessage = 'Lỗi: Không thể lấy căn số âm';
        return;
      }
      double result = math.sqrt(value);
      _display = _logic.formatResult(result.toString());
      _logic.setShouldResetInput(true);
    } catch (_) {
      _errorMessage = 'Lỗi';
    }
  }

  void _onCubeRoot() {
    try {
      double value = double.parse(_display);
      double result = math.pow(value.abs(), 1 / 3).toDouble();
      if (value < 0) result = -result;
      _display = _logic.formatResult(result.toString());
      _logic.setShouldResetInput(true);
    } catch (_) {
      _errorMessage = 'Lỗi';
    }
  }

  void _onFactorial() {
    try {
      double value = double.parse(_display);
      if (value < 0 || value != value.roundToDouble()) {
        _errorMessage = 'Lỗi: Phải là số nguyên không âm';
        return;
      }
      int n = value.toInt();
      double result = _logic.evaluateFactorial(n);
      _display = _logic.formatResult(result.toString());
      _logic.setShouldResetInput(true);
    } catch (_) {
      _errorMessage = 'Lỗi';
    }
  }

  void _onMemoryAdd() {
    try {
      double current = double.parse(_display);
      double memVal = double.parse(_memory);
      _memory = _logic.formatResult((memVal + current).toString());
      _hasMemory = _memory != '0';
      _storageService.saveMemory(_memory);
    } catch (_) {}
  }

  void _onMemorySubtract() {
    try {
      double current = double.parse(_display);
      double memVal = double.parse(_memory);
      _memory = _logic.formatResult((memVal - current).toString());
      _hasMemory = _memory != '0';
      _storageService.saveMemory(_memory);
    } catch (_) {}
  }

  void _onMemoryRecall() {
    _display = _logic.formatResult(double.parse(_memory).toString());
    _logic.setShouldResetInput(true);
  }

  void _onMemoryClear() {
    _memory = '0';
    _hasMemory = false;
    _storageService.saveMemory(_memory);
  }

  String _evaluate(String expr) {
    if (expr.isEmpty) return '0';

    try {
      String processed = _preprocessExpression(expr);
      Parser parser = Parser();
      ContextModel contextModel = ContextModel();
      Expression exp = parser.parse(processed);
      double result = exp.evaluate(EvaluationType.REAL, contextModel);

      if (result.isNaN) return 'Lỗi';
      if (result.isInfinite) return 'Vô cực';

      return _logic.formatResult(result.toString());
    } catch (e) {
      return 'Lỗi';
    }
  }

  String _preprocessExpression(String expr) {
    String result = expr;

    result = result.replaceAll('×', '*');
    result = result.replaceAll('÷', '/');
    result = result.replaceAll('−', '-');

    result = result.replaceAll('π', math.pi.toString());
    result = result.replaceAll('Π', math.pi.toString());

    result = result.replaceAllMapped(
      RegExp(r'(\d)(\()'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    result = result.replaceAllMapped(
      RegExp(r'(\))(\d)'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    result = result.replaceAllMapped(
      RegExp(r'(\))(\()'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );

    return result;
  }

  void _handleProgrammerInput(String value) {
    switch (value) {
      case 'C':
        _programmerInput = '';
        _display = '0';
        _previousValue = null;
        _pendingBitwiseOp = null;
        break;
      case 'CE':
        _programmerInput = '';
        _display = '0';
        break;
      case '⌫':
        if (_programmerInput.isNotEmpty) {
          _programmerInput = _programmerInput.substring(0, _programmerInput.length - 1);
          _display = _programmerInput.isEmpty ? '0' : _programmerInput;
        }
        break;
      case 'AND':
      case 'OR':
      case 'XOR':
        _onBitwiseTwoOperand(value);
        break;
      case 'NOT':
        _onBitwiseNot();
        break;
      case '<<':
      case '>>':
        _onBitShift(value);
        break;
      case 'BIN':
      case 'OCT':
      case 'DEC':
      case 'HEX':
        _changeBase(value);
        break;
      case '=':
        _onProgrammerEquals();
        break;
      default:
        if (_isValidDigit(value)) {
          _programmerInput += value.toUpperCase();
          _display = _programmerInput;
        }
    }
    notifyListeners();
  }

  bool _isValidDigit(String digit) {
    int d = int.tryParse(digit) ?? -1;
    switch (_base) {
      case 2: return d >= 0 && d <= 1;
      case 8: return d >= 0 && d <= 7;
      case 10: return d >= 0 && d <= 9;
      case 16: return RegExp(r'^[0-9A-Fa-f]$').hasMatch(digit);
      default: return false;
    }
  }

  void _changeBase(String newBase) {
    if (_programmerInput.isEmpty) {
      _base = newBase == 'BIN' ? 2 : (newBase == 'OCT' ? 8 : (newBase == 'DEC' ? 10 : 16));
      return;
    }

    try {
      int value = int.parse(_programmerInput, radix: _base);
      _base = newBase == 'BIN' ? 2 : (newBase == 'OCT' ? 8 : (newBase == 'DEC' ? 10 : 16));
      _programmerInput = value.toRadixString(_base).toUpperCase();
      _display = _programmerInput;
    } catch (_) {
      _programmerInput = '';
      _display = '0';
    }
  }

  void _onBitwiseTwoOperand(String op) {
    if (_programmerInput.isEmpty) return;
    try {
      int value = int.parse(_programmerInput, radix: _base);
      if (_previousValue != null && _pendingBitwiseOp != null) {
        int result = _applyBitwise(_previousValue!, _pendingBitwiseOp!, value);
        _previousValue = result;
        _programmerInput = result.toRadixString(_base).toUpperCase();
        _display = _programmerInput;
      } else {
        _previousValue = value;
        _pendingBitwiseOp = _getBitwiseOpCode(op);
        _programmerInput = '';
      }
    } catch (_) {
      _errorMessage = 'Lỗi';
    }
  }

  int _getBitwiseOpCode(String op) {
    switch (op) {
      case 'AND': return 0;
      case 'OR': return 1;
      case 'XOR': return 2;
      case '<<': return 3;
      case '>>': return 4;
      default: return -1;
    }
  }

  int _applyBitwise(int a, int op, int b) {
    switch (op) {
      case 0: return a & b;
      case 1: return a | b;
      case 2: return a ^ b;
      case 3: return a << b;
      case 4: return a >> b;
      default: return b;
    }
  }

  void _onBitwiseNot() {
    if (_programmerInput.isEmpty) return;
    try {
      int value = int.parse(_programmerInput, radix: _base);
      int result = ~value;
      _programmerInput = result.toRadixString(_base).toUpperCase();
      _display = _programmerInput;
    } catch (_) {
      _errorMessage = 'Lỗi';
    }
  }

  void _onBitShift(String op) {
    if (_programmerInput.isEmpty) return;
    try {
      int value = int.parse(_programmerInput, radix: _base);
      if (_previousValue != null && _pendingBitwiseOp != null) {
        int result = _applyBitwise(_previousValue!, _getBitwiseOpCode(op), value);
        _previousValue = result;
        _programmerInput = result.toRadixString(_base).toUpperCase();
        _display = _programmerInput;
      } else {
        _previousValue = value;
        _pendingBitwiseOp = _getBitwiseOpCode(op);
        _programmerInput = '';
      }
    } catch (_) {
      _errorMessage = 'Lỗi';
    }
  }

  void _onProgrammerEquals() {
    if (_previousValue != null && _pendingBitwiseOp != null && _programmerInput.isNotEmpty) {
      try {
        int value = int.parse(_programmerInput, radix: _base);
        int result = _applyBitwise(_previousValue!, _pendingBitwiseOp!, value);
        _programmerInput = result.toRadixString(_base).toUpperCase();
        _display = _programmerInput;
        _previousValue = null;
        _pendingBitwiseOp = null;
      } catch (_) {
        _errorMessage = 'Lỗi';
      }
    } else if (_programmerInput.isNotEmpty) {
      try {
        int value = int.parse(_programmerInput, radix: _base);
        _display = '${value.toRadixString(_base).toUpperCase()}\nBIN: ${value.toRadixString(2)}\nOCT: ${value.toRadixString(8)}\nDEC: ${value.toRadixString(10)}\nHEX: ${value.toRadixString(16).toUpperCase()}';
      } catch (_) {
        _errorMessage = 'Lỗi';
      }
    }
  }

  String getFullExpression() {
    if (_expression.isEmpty) return _display;
    return '$_expression$_display';
  }
}
