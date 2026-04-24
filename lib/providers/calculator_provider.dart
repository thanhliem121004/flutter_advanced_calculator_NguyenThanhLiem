import 'package:flutter/foundation.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../services/storage_service.dart';
import '../utils/calculator_logic.dart';
import '../utils/expression_parser.dart';

class CalculatorProvider extends ChangeNotifier {
  final StorageService _storageService;

  CalculatorMode _mode = CalculatorMode.basic;
  AngleMode _angleMode = AngleMode.degrees;
  int _precision = 10;

  // _expression: biểu thức đang nhập (hiển thị chính)
  // _result: kết quả sau khi ấn =
  // _previousExpression: biểu thức trước đó (hiển thị phụ)
  String _expression = '';
  String _result = '0';
  String _previousExpression = '';

  String _memory = '0';
  bool _hasMemory = false;
  String? _errorMessage;
  bool _isSecondFunction = false;
  bool _hasError = false;
  int _base = 10;

  CalculatorProvider(this._storageService);

  CalculatorMode get mode => _mode;
  AngleMode get angleMode => _angleMode;
  int get precision => _precision;
  bool get hasMemory => _hasMemory;
  String? get errorMessage => _errorMessage;
  bool get isSecondFunction => _isSecondFunction;
  int get base => _base;
  bool get isRadiansMode => _angleMode == AngleMode.radians;
  String get memory => _memory;

  // display: hiển thị chính (dòng lớn)
  //   Khi đang nhập: hiển thị biểu thức (_expression)
  //   Khi có kết quả: hiển thị kết quả (_result)
  String get display {
    if (_expression.isNotEmpty) {
      if (_mode == CalculatorMode.programmer && _base != 10) {
        return _formatProgrammerExpression(_expression, _base);
      }
      return _expression;
    }
    return _result;
  }

  // expression: hiển thị phụ (dòng nhỏ phía trên)
  String get expression => _previousExpression;

  String _formatProgrammerExpression(String expr, int base) {
    String prefix;
    switch (base) {
      case 16:
        prefix = '0x';
        break;
      case 2:
        prefix = '0b';
        break;
      case 8:
        prefix = '0o';
        break;
      default:
        return expr;
    }

    StringBuffer result = StringBuffer();
    StringBuffer currentNum = StringBuffer();

    for (int i = 0; i < expr.length; i++) {
      final c = expr[i];
      final isHexChar =
          (c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) ||
          (c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 70) ||
          (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 102);

      if (isHexChar) {
        currentNum.write(c);
      } else {
        if (currentNum.isNotEmpty) {
          result.write(prefix);
          result.write(currentNum);
          currentNum.clear();
        }
        String op = c;
        if (i + 1 < expr.length) {
          String twoChar = expr.substring(
            i,
            i + 2 > expr.length ? expr.length : i + 2,
          );
          if (twoChar == '^^') {
            op = ' XOR ';
            i++;
          } else if (twoChar == '<<') {
            op = ' SHL ';
            i++;
          } else if (twoChar == '>>') {
            op = ' SHR ';
            i++;
          } else if (c == '&') {
            op = ' AND ';
          } else if (c == '|') {
            op = ' OR ';
          } else if (c == '~') {
            op = 'NOT ';
          } else if (c == '×' || c == '÷' || c == '+' || c == '-') {
            op = ' $c ';
          }
        } else {
          if (c == '&')
            op = ' AND ';
          else if (c == '|')
            op = ' OR ';
          else if (c == '~')
            op = 'NOT ';
          else if (c == '×' || c == '÷' || c == '+' || c == '-')
            op = ' $c ';
        }
        result.write(op);
      }
    }
    if (currentNum.isNotEmpty) {
      result.write(prefix);
      result.write(currentNum);
    }
    return result.toString();
  }

  Future<void> loadSettings() async {
    final settings = await _storageService.loadSettings();
    _mode = settings.defaultMode;
    _angleMode = settings.angleMode;
    _precision = settings.decimalPrecision;
    _memory = await _storageService.loadMemory();
    _hasMemory = _memory != '0';
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
    _expression = '';
    _result = '0';
    _previousExpression = '';
    _errorMessage = null;
    _hasError = false;
    notifyListeners();
  }

  void setAngleMode(AngleMode mode) {
    _angleMode = mode;
    notifyListeners();
  }

  void toggleAngleMode() {
    setAngleMode(
      _angleMode == AngleMode.degrees ? AngleMode.radians : AngleMode.degrees,
    );
  }

  void setPrecision(int value) {
    _precision = value;
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
        _expression = '';
        _result = '0';
        _previousExpression = '';
        _hasError = false;
        break;
      case 'CE':
        _expression = '';
        _hasError = false;
        break;
      case '⌫':
        _deleteLastCharacter();
        break;
      case '=':
        _calculateResult();
        break;
      case '±':
        _toggleSign();
        break;
      case '+':
      case '−':
      case '×':
      case '÷':
        _appendOperator(value);
        break;
      case '%':
        _appendOperator('%');
        break;
      case '(':
      case ')':
        _appendParenthesis(value);
        break;
      case '.':
        _appendDecimal();
        break;
      case 'π':
      case 'Π':
        _insertConstant('π');
        break;
      case 'e':
        _insertConstant('e');
        break;
      case 'sin':
      case 'cos':
      case 'tan':
        _applyFunction(value);
        break;
      case 'asin':
      case 'acos':
      case 'atan':
        _applyFunction(value);
        break;
      case 'ln':
        _applyFunction('ln');
        break;
      case 'log':
        _applyFunction('log');
        break;
      case 'x²':
        _applySquare();
        break;
      case 'x³':
        _applyCube();
        break;
      case 'xʸ':
        _applyPower();
        break;
      case '√':
        _applySqrt();
        break;
      case '∛':
        _applyFunction('cbrt');
        break;
      case '!':
        _applyFactorial();
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
          _appendNumber(value);
        }
    }

    notifyListeners();
  }

  // === INPUT METHODS (giống main project) ===

  void _appendNumber(String number) {
    if (_hasError) {
      _expression = '';
      _result = '0';
      _hasError = false;
    }
    _expression += number;
  }

  void _appendOperator(String op) {
    if (_hasError) {
      _expression = _result != 'Lỗi' ? _result : '';
      _hasError = false;
    }
    // Nếu expression rỗng và có kết quả trước đó, dùng kết quả
    if (_expression.isEmpty && _result != '0' && _result != 'Lỗi') {
      _expression = _result;
    }
    // Thay thế toán tử cuối nếu đã có
    if (_expression.isNotEmpty) {
      final last = _expression[_expression.length - 1];
      if (['+', '−', '×', '÷', '%'].contains(last)) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    }
    _expression += op;
  }

  void _appendDecimal() {
    if (_hasError) {
      _expression = '0';
      _hasError = false;
    }
    // Kiểm tra số hiện tại đã có dấu chấm chưa
    final parts = _expression.split(RegExp(r'[+\-×÷%\(\)]'));
    final lastPart = parts.isNotEmpty ? parts.last : '';
    if (!lastPart.contains('.')) {
      if (_expression.isEmpty ||
          !RegExp(r'[0-9]').hasMatch(_expression[_expression.length - 1])) {
        _expression += '0';
      }
      _expression += '.';
    }
  }

  void _appendParenthesis(String paren) {
    if (_hasError) {
      _expression = '';
      _hasError = false;
    }
    if (paren == '(') {
      int openCount = '('.allMatches(_expression).length;
      int closeCount = ')'.allMatches(_expression).length;

      if (_expression.isEmpty ||
          _expression.endsWith('(') ||
          [
            '+',
            '−',
            '×',
            '÷',
            '%',
          ].contains(_expression[_expression.length - 1])) {
        _expression += '(';
      } else if (openCount > closeCount) {
        _expression += ')';
      } else {
        _expression += '(';
      }
    } else {
      _expression += ')';
    }
  }

  void _insertConstant(String constant) {
    if (_hasError) {
      _expression = '';
      _hasError = false;
    }
    _expression += constant;
  }

  void _applyFunction(String funcName) {
    if (_hasError) {
      _expression = '';
      _hasError = false;
    }
    _expression += '$funcName(';
  }

  void _applySquare() {
    if (_expression.isNotEmpty) {
      _expression = '($_expression)^2';
    } else if (_result != '0' && _result != 'Lỗi') {
      _expression = '($_result)^2';
    }
  }

  void _applyCube() {
    if (_expression.isNotEmpty) {
      _expression = '($_expression)^3';
    } else if (_result != '0' && _result != 'Lỗi') {
      _expression = '($_result)^3';
    }
  }

  void _applyPower() {
    if (_expression.isEmpty && _result != '0' && _result != 'Lỗi') {
      _expression = '$_result^';
    } else if (_expression.isNotEmpty) {
      _expression += '^';
    }
  }

  void _applySqrt() {
    if (_hasError) {
      _expression = '';
      _hasError = false;
    }
    if (_expression.isEmpty && _result != '0' && _result != 'Lỗi') {
      _expression = 'sqrt($_result)';
    } else {
      _expression += 'sqrt(';
    }
  }

  void _applyFactorial() {
    if (_expression.isNotEmpty) {
      _expression = '($_expression)!';
    } else if (_result != '0' && _result != 'Lỗi') {
      _expression = '($_result)!';
    }
  }

  void _toggleSign() {
    if (_expression.isNotEmpty) {
      if (_expression.startsWith('-')) {
        _expression = _expression.substring(1);
      } else {
        _expression = '-$_expression';
      }
    } else if (_result != '0' && _result != 'Lỗi') {
      if (_result.startsWith('-')) {
        _result = _result.substring(1);
      } else {
        _result = '-$_result';
      }
    }
  }

  void _deleteLastCharacter() {
    if (_expression.isNotEmpty) {
      // Xóa cả tên hàm nếu đang ở cuối
      final funcPatterns = [
        'sin(',
        'cos(',
        'tan(',
        'asin(',
        'acos(',
        'atan(',
        'ln(',
        'log(',
        'sqrt(',
        'cbrt(',
      ];
      bool found = false;
      for (final func in funcPatterns) {
        if (_expression.toLowerCase().endsWith(func)) {
          _expression = _expression.substring(
            0,
            _expression.length - func.length,
          );
          found = true;
          break;
        }
      }
      if (!found) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    }
  }

  void _calculateResult() {
    if (_expression.isEmpty) return;

    String exprToEval = _expression;
    if (_mode == CalculatorMode.programmer && _base != 10) {
      exprToEval = _addBasePrefixes(_expression, _base);
    }

    final parser = ExpressionParser(angleMode: _angleMode);
    final evalResult = parser.evaluate(exprToEval, precision: _precision);

    _previousExpression = _expression;

    if (evalResult == 'Lỗi') {
      _result = 'Lỗi';
      _hasError = true;
      _expression = '';
      return;
    }

    if (_mode == CalculatorMode.programmer) {
      final intVal = double.tryParse(evalResult)?.toInt();
      if (intVal != null) {
        _result = CalculatorLogic.toBase(intVal, _base);
      } else {
        _result = evalResult;
      }
    } else {
      _result = evalResult;
    }

    _expression = '';
  }

  String _addBasePrefixes(String expr, int base) {
    String prefix;
    switch (base) {
      case 16:
        prefix = '0x';
        break;
      case 2:
        prefix = '0b';
        break;
      case 8:
        prefix = '0o';
        break;
      default:
        return expr;
    }

    StringBuffer result = StringBuffer();
    StringBuffer currentNum = StringBuffer();

    for (int i = 0; i < expr.length; i++) {
      final c = expr[i];
      final isHexChar =
          (c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) ||
          (c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 70) ||
          (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 102) ||
          c == '.';

      if (isHexChar) {
        currentNum.write(c);
      } else {
        if (currentNum.isNotEmpty) {
          result.write(prefix);
          result.write(currentNum);
          currentNum.clear();
        }
        result.write(c);
      }
    }
    if (currentNum.isNotEmpty) {
      result.write(prefix);
      result.write(currentNum);
    }
    return result.toString();
  }

  // === MEMORY ===

  void _onMemoryAdd() {
    try {
      double current = double.parse(_result);
      double memVal = double.parse(_memory);
      _memory = CalculatorLogic.formatResult(memVal + current, _precision);
      _hasMemory = _memory != '0';
      _storageService.saveMemory(_memory);
    } catch (_) {}
  }

  void _onMemorySubtract() {
    try {
      double current = double.parse(_result);
      double memVal = double.parse(_memory);
      _memory = CalculatorLogic.formatResult(memVal - current, _precision);
      _hasMemory = _memory != '0';
      _storageService.saveMemory(_memory);
    } catch (_) {}
  }

  void _onMemoryRecall() {
    _expression += _memory;
  }

  void _onMemoryClear() {
    _memory = '0';
    _hasMemory = false;
    _storageService.saveMemory(_memory);
  }

  // === PROGRAMMER MODE ===

  void _handleProgrammerInput(String value) {
    switch (value) {
      case 'AC':
        _expression = '';
        _result = '0';
        _previousExpression = '';
        _hasError = false;
        break;
      case 'CE':
        _expression = '';
        _hasError = false;
        break;
      case '⌫':
        _deleteLastCharacter();
        break;
      case '=':
        _calculateResult();
        break;
      case 'AND':
        _appendOperator('&');
        break;
      case 'OR':
        _appendOperator('|');
        break;
      case 'XOR':
        _appendOperator('^^');
        break;
      case 'NOT':
        if (_hasError) {
          _expression = '';
          _hasError = false;
        }
        _expression += '~';
        break;
      case '<<':
        _appendOperator('<<');
        break;
      case '>>':
        _appendOperator('>>');
        break;
      case 'BIN':
        _changeBase(2);
        break;
      case 'OCT':
        _changeBase(8);
        break;
      case 'DEC':
        _changeBase(10);
        break;
      case 'HEX':
        _changeBase(16);
        break;
      case '+':
      case '−':
      case '×':
      case '÷':
        _appendOperator(value);
        break;
      default:
        if (_isValidDigit(value)) {
          if (_hasError) {
            _expression = '';
            _result = '0';
            _hasError = false;
          }
          _expression += value.toUpperCase();
        }
    }
    notifyListeners();
  }

  void _changeBase(int newBase) {
    // Chuyển đổi kết quả sang cơ số mới
    if (_result != '0' && _result != 'Lỗi') {
      try {
        int intVal = CalculatorLogic.parseBase(_result);
        _base = newBase;
        _result = CalculatorLogic.toBase(intVal, _base);
      } catch (_) {
        _base = newBase;
      }
    } else {
      _base = newBase;
    }
  }

  bool _isValidDigit(String digit) {
    if (digit.length != 1) return false;

    switch (_base) {
      case 2:
        return digit == '0' || digit == '1';
      case 8:
        int? d = int.tryParse(digit);
        return d != null && d >= 0 && d <= 7;
      case 10:
        return int.tryParse(digit) != null;
      case 16:
        return RegExp(r'^[0-9A-Fa-f]$').hasMatch(digit);
      default:
        return false;
    }
  }

  String getFullExpression() {
    if (_expression.isEmpty) return _result;
    return _expression;
  }
}
