import 'dart:math' as math;
import 'calculator_logic.dart';
import '../models/calculator_settings.dart';

class ExpressionParser {
  final AngleMode angleMode;

  ExpressionParser({this.angleMode = AngleMode.degrees});

  String evaluate(String expression, {int precision = 10}) {
    try {
      String processed = _preprocess(expression);
      final result = _parseBitwiseOr(processed, 0);
      if (result.pos < processed.length) {
        throw FormatException('Unexpected character at position ${result.pos}');
      }
      return CalculatorLogic.formatResult(result.value, precision);
    } catch (e) {
      return 'Lỗi';
    }
  }

  String _preprocess(String expr) {
    expr = expr.replaceAll(' ', '');
    expr = expr.replaceAll('×', '*');
    expr = expr.replaceAll('÷', '/');
    expr = expr.replaceAll('−', '-');
    expr = expr.replaceAll('π', '(${math.pi})');

    expr = expr.replaceAll('asin', 'ASIN');
    expr = expr.replaceAll('acos', 'ACOS');
    expr = expr.replaceAll('atan', 'ATAN');
    expr = expr.replaceAll('sin', 'SIN');
    expr = expr.replaceAll('cos', 'COS');
    expr = expr.replaceAll('tan', 'TAN');
    expr = expr.replaceAll('ln', 'LN');
    expr = expr.replaceAll('log', 'LOG');
    expr = expr.replaceAll('sqrt', 'SQRT');
    expr = expr.replaceAll('cbrt', 'CBRT');

    expr = expr.replaceAllMapped(
      RegExp(r'(?<![0-9a-fA-Fx])e(?![0-9a-fA-F])'),
      (m) => '(${math.e})',
    );

    StringBuffer result = StringBuffer();
    bool inBaseNumber = false;
    for (int i = 0; i < expr.length; i++) {
      result.write(expr[i]);

      if (i + 1 < expr.length) {
        final current = expr[i];
        final next = expr[i + 1];

        if (current == '0' &&
            (next == 'x' ||
                next == 'X' ||
                next == 'b' ||
                next == 'B' ||
                next == 'o' ||
                next == 'O')) {
          inBaseNumber = true;
          continue;
        }

        if (inBaseNumber) {
          if (_isHexDigit(next) || _isDigit(next)) {
            continue;
          } else {
            inBaseNumber = false;
          }
        }

        if ((_isDigit(current) || current == ')') &&
            (next == '(' || _isLetter(next))) {
          result.write('*');
        }
        if (current == ')' && (_isDigit(next))) {
          result.write('*');
        }
      }
    }

    return result.toString();
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isHexDigit(String c) =>
      _isDigit(c) ||
      (c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 70) ||
      (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 102);
  bool _isLetter(String c) =>
      (c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 90) ||
      (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 122);

  _Result _parseBitwiseOr(String expr, int pos) {
    var result = _parseBitwiseXor(expr, pos);
    while (result.pos < expr.length && expr[result.pos] == '|') {
      final right = _parseBitwiseXor(expr, result.pos + 1);
      result = _Result(
        (result.value.toInt() | right.value.toInt()).toDouble(),
        right.pos,
      );
    }
    return result;
  }

  _Result _parseBitwiseXor(String expr, int pos) {
    var result = _parseBitwiseAnd(expr, pos);
    while (result.pos < expr.length) {
      if (result.pos + 1 < expr.length &&
          expr.substring(result.pos, result.pos + 2) == '^^') {
        final right = _parseBitwiseAnd(expr, result.pos + 2);
        result = _Result(
          (result.value.toInt() ^ right.value.toInt()).toDouble(),
          right.pos,
        );
      } else {
        break;
      }
    }
    return result;
  }

  _Result _parseBitwiseAnd(String expr, int pos) {
    var result = _parseShift(expr, pos);
    while (result.pos < expr.length && expr[result.pos] == '&') {
      final right = _parseShift(expr, result.pos + 1);
      result = _Result(
        (result.value.toInt() & right.value.toInt()).toDouble(),
        right.pos,
      );
    }
    return result;
  }

  _Result _parseShift(String expr, int pos) {
    var result = _parseExpression(expr, pos);
    while (result.pos + 1 < expr.length) {
      final twoChar = expr.substring(result.pos, result.pos + 2);
      if (twoChar == '<<') {
        final right = _parseExpression(expr, result.pos + 2);
        result = _Result(
          (result.value.toInt() << right.value.toInt()).toDouble(),
          right.pos,
        );
      } else if (twoChar == '>>') {
        final right = _parseExpression(expr, result.pos + 2);
        result = _Result(
          (result.value.toInt() >> right.value.toInt()).toDouble(),
          right.pos,
        );
      } else {
        break;
      }
    }
    return result;
  }

  _Result _parseExpression(String expr, int pos) {
    var result = _parseTerm(expr, pos);
    while (result.pos < expr.length) {
      final op = expr[result.pos];
      if (op != '+' && op != '-') break;
      final right = _parseTerm(expr, result.pos + 1);
      if (op == '+') {
        result = _Result(result.value + right.value, right.pos);
      } else {
        result = _Result(result.value - right.value, right.pos);
      }
    }
    return result;
  }

  _Result _parseTerm(String expr, int pos) {
    var result = _parsePower(expr, pos);
    while (result.pos < expr.length) {
      final op = expr[result.pos];
      if (op != '*' && op != '/' && op != '%') break;
      final right = _parsePower(expr, result.pos + 1);
      if (op == '*') {
        result = _Result(result.value * right.value, right.pos);
      } else if (op == '/') {
        if (right.value == 0) throw ArgumentError('Division by zero');
        result = _Result(result.value / right.value, right.pos);
      } else {
        result = _Result(result.value % right.value, right.pos);
      }
    }
    return result;
  }

  _Result _parsePower(String expr, int pos) {
    var result = _parseUnary(expr, pos);
    while (result.pos < expr.length && expr[result.pos] == '^') {
      if (result.pos + 1 < expr.length && expr[result.pos + 1] == '^') break;
      final right = _parseUnary(expr, result.pos + 1);
      result = _Result(
        math.pow(result.value, right.value).toDouble(),
        right.pos,
      );
    }
    return result;
  }

  _Result _parseUnary(String expr, int pos) {
    if (pos < expr.length && expr[pos] == '-') {
      final result = _parseUnary(expr, pos + 1);
      return _Result(-result.value, result.pos);
    }
    if (pos < expr.length && expr[pos] == '+') {
      return _parseUnary(expr, pos + 1);
    }
    if (pos < expr.length && expr[pos] == '~') {
      final result = _parseUnary(expr, pos + 1);
      return _Result((~result.value.toInt()).toDouble(), result.pos);
    }
    return _parseAtom(expr, pos);
  }

  _Result _parseAtom(String expr, int pos) {
    for (final func in [
      'ASIN',
      'ACOS',
      'ATAN',
      'SIN',
      'COS',
      'TAN',
      'LN',
      'LOG',
      'SQRT',
      'CBRT',
    ]) {
      if (expr.substring(pos).startsWith(func)) {
        int funcEnd = pos + func.length;
        if (funcEnd < expr.length && expr[funcEnd] == '(') {
          final inner = _parseBitwiseOr(expr, funcEnd + 1);
          if (inner.pos >= expr.length || expr[inner.pos] != ')') {
            throw FormatException('Missing closing parenthesis');
          }
          double value = inner.value;
          double result;
          switch (func) {
            case 'SIN':
              result = CalculatorLogic.sin(value, angleMode);
              break;
            case 'COS':
              result = CalculatorLogic.cos(value, angleMode);
              break;
            case 'TAN':
              result = CalculatorLogic.tan(value, angleMode);
              break;
            case 'ASIN':
              result = CalculatorLogic.asin(value, angleMode);
              break;
            case 'ACOS':
              result = CalculatorLogic.acos(value, angleMode);
              break;
            case 'ATAN':
              result = CalculatorLogic.atan(value, angleMode);
              break;
            case 'LN':
              result = CalculatorLogic.ln(value);
              break;
            case 'LOG':
              result = CalculatorLogic.log10(value);
              break;
            case 'SQRT':
              result = CalculatorLogic.squareRoot(value);
              break;
            case 'CBRT':
              result = CalculatorLogic.cubeRoot(value);
              break;
            default:
              throw FormatException('Unknown function: $func');
          }
          return _Result(result, inner.pos + 1);
        }
      }
    }

    if (pos < expr.length && expr[pos] == '(') {
      final result = _parseBitwiseOr(expr, pos + 1);
      if (result.pos >= expr.length || expr[result.pos] != ')') {
        throw FormatException('Missing closing parenthesis');
      }
      var atomResult = _Result(result.value, result.pos + 1);
      if (atomResult.pos < expr.length && expr[atomResult.pos] == '!') {
        atomResult = _Result(
          CalculatorLogic.factorial(atomResult.value),
          atomResult.pos + 1,
        );
      }
      return atomResult;
    }

    if (pos + 1 < expr.length &&
        expr[pos] == '0' &&
        (expr[pos + 1] == 'x' || expr[pos + 1] == 'X')) {
      int hexStart = pos + 2;
      int hexEnd = hexStart;
      while (hexEnd < expr.length && _isHexDigit(expr[hexEnd])) {
        hexEnd++;
      }
      if (hexEnd == hexStart) {
        throw FormatException('Invalid hex literal');
      }
      int hexVal = int.parse(expr.substring(hexStart, hexEnd), radix: 16);
      return _Result(hexVal.toDouble(), hexEnd);
    }

    if (pos + 1 < expr.length &&
        expr[pos] == '0' &&
        (expr[pos + 1] == 'b' || expr[pos + 1] == 'B')) {
      int binStart = pos + 2;
      int binEnd = binStart;
      while (binEnd < expr.length &&
          (expr[binEnd] == '0' || expr[binEnd] == '1')) {
        binEnd++;
      }
      if (binEnd == binStart) {
        throw FormatException('Invalid binary literal');
      }
      int binVal = int.parse(expr.substring(binStart, binEnd), radix: 2);
      return _Result(binVal.toDouble(), binEnd);
    }

    if (pos + 1 < expr.length &&
        expr[pos] == '0' &&
        (expr[pos + 1] == 'o' || expr[pos + 1] == 'O')) {
      int octStart = pos + 2;
      int octEnd = octStart;
      while (octEnd < expr.length &&
          expr[octEnd].codeUnitAt(0) >= 48 &&
          expr[octEnd].codeUnitAt(0) <= 55) {
        octEnd++;
      }
      if (octEnd == octStart) {
        throw FormatException('Invalid octal literal');
      }
      int octVal = int.parse(expr.substring(octStart, octEnd), radix: 8);
      return _Result(octVal.toDouble(), octEnd);
    }

    int start = pos;
    while (pos < expr.length && (_isDigit(expr[pos]) || expr[pos] == '.')) {
      pos++;
    }
    if (pos == start) {
      throw FormatException('Expected number at position $start');
    }
    double value = double.parse(expr.substring(start, pos));

    if (pos < expr.length && expr[pos] == '!') {
      value = CalculatorLogic.factorial(value);
      pos++;
    }

    return _Result(value, pos);
  }
}

class _Result {
  final double value;
  final int pos;
  _Result(this.value, this.pos);
}
