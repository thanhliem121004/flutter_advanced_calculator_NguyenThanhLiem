import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

class ExpressionParser {
  final bool useDegrees;
  final int precision;

  ExpressionParser({
    this.useDegrees = true,
    this.precision = 10,
  });

  String parse(String expression) {
    if (expression.isEmpty) return '0';
    try {
      String processed = _preprocess(expression);
      String result = _calculate(processed);
      return _formatResult(result);
    } catch (e) {
      return 'Lỗi';
    }
  }

  String _preprocess(String expr) {
    String result = expr;

    result = result.replaceAll('×', '*');
    result = result.replaceAll('÷', '/');
    result = result.replaceAll('−', '-');

    result = _expandFactorial(result);

    result = result.replaceAll('π', '${math.pi}');
    result = result.replaceAll('Π', '${math.pi}');
    result = result.replaceAllMapped(
      RegExp(r'(?<![a-zA-Z0-9])pi(?![a-zA-Z0-9])'),
      (m) => '${math.pi}',
    );
    result = result.replaceAll('√', 'sqrt');

    result = _addImplicitMultiplication(result);
    result = _replaceE(result);

    return result;
  }

  String _expandFactorial(String expr) {
    RegExp factorialPattern = RegExp(r'(\d+)!');
    return expr.replaceAllMapped(factorialPattern, (match) {
      int n = int.parse(match.group(1)!);
      return _factorial(n).toString();
    });
  }

  int _factorial(int n) {
    if (n < 0) throw FormatException('Giai thừa không xác định cho số âm');
    if (n > 170) throw FormatException('Giai thừa quá lớn');
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  String _addImplicitMultiplication(String expr) {
    String result = expr;

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

  String _replaceE(String expr) {
    StringBuffer sb = StringBuffer();
    int i = 0;
    while (i < expr.length) {
      if (expr[i] == 'e' || expr[i] == 'E') {
        bool prevOk = (i == 0) || (!_isAlphanumeric(expr[i - 1]));
        bool nextOk = (i == expr.length - 1) || (!_isAlphanumeric(expr[i + 1]) && expr[i + 1] != '.');
        if (prevOk && nextOk) {
          sb.write(math.e);
        } else {
          sb.write(expr[i]);
        }
      } else {
        sb.write(expr[i]);
      }
      i++;
    }
    return sb.toString();
  }

  bool _isAlphanumeric(String c) {
    if (c.isEmpty) return false;
    int code = c.codeUnitAt(0);
    bool isDigit = (code >= 48 && code <= 57);
    bool isAlpha = (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
    return isDigit || isAlpha;
  }

  String _calculate(String expression) {
    if (expression.isEmpty) return '0';

    String processed = expression;
    processed = _evaluateTrigFunctions(processed);
    processed = _evaluateLogFunctions(processed);

    Parser parser = Parser();
    ContextModel contextModel = ContextModel();
    Expression exp = parser.parse(processed);
    double evalResult = exp.evaluate(EvaluationType.REAL, contextModel);

    if (evalResult.isNaN) return 'Lỗi';
    if (evalResult.isInfinite) return 'Vô cực';

    return evalResult.toString();
  }

  String _evaluateTrigFunctions(String expr) {
    String result = expr;

    result = _applyFunc(result, 'sin', (x) {
      double val = useDegrees ? x * math.pi / 180 : x;
      return math.sin(val);
    });
    result = _applyFunc(result, 'cos', (x) {
      double val = useDegrees ? x * math.pi / 180 : x;
      return math.cos(val);
    });
    result = _applyFunc(result, 'tan', (x) {
      double val = useDegrees ? x * math.pi / 180 : x;
      return math.tan(val);
    });

    return result;
  }

  String _evaluateLogFunctions(String expr) {
    String result = expr;

    result = _applyFunc(result, 'ln', (x) => math.log(x));
    result = _applyFunc(result, 'log', (x) => math.log(x) / math.ln10);

    return result;
  }

  String _applyFunc(String expr, String funcName, double Function(double) operation) {
    RegExp pattern = RegExp('$funcName\\(([^)]+)\\)');
    while (pattern.hasMatch(expr)) {
      expr = expr.replaceAllMapped(pattern, (match) {
        try {
          double arg = double.parse(match.group(1)!);
          return operation(arg).toString();
        } catch (_) {
          return '0';
        }
      });
    }
    return expr;
  }

  String _formatResult(String result) {
    if (result == 'Lỗi' || result == 'Vô cực') return result;

    double? num = double.tryParse(result);
    if (num == null) return result;

    if (num == num.roundToDouble() && num.abs() < 1e15) {
      return num.toInt().toString();
    }

    String formatted = num.toStringAsFixed(precision);
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');

    return formatted;
  }

  bool validateExpression(String expression) {
    int parenCount = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') parenCount++;
      if (expression[i] == ')') parenCount--;
      if (parenCount < 0) return false;
    }
    if (parenCount != 0) return false;

    if (expression.endsWith('+') ||
        expression.endsWith('-') ||
        expression.endsWith('*') ||
        expression.endsWith('/') ||
        expression.endsWith('×') ||
        expression.endsWith('÷')) {
      return false;
    }

    return true;
  }
}
