import 'dart:math' as math;
import '../models/calculator_settings.dart';

class CalculatorLogic {
  static double factorial(double n) {
    if (n < 0 || n != n.truncateToDouble()) {
      throw ArgumentError('Factorial requires non-negative integer');
    }
    int val = n.toInt();
    if (val > 170) return double.infinity;
    double result = 1;
    for (int i = 2; i <= val; i++) {
      result *= i;
    }
    return result;
  }

  static double sin(double value, AngleMode mode) {
    double angle = mode == AngleMode.degrees ? value * math.pi / 180 : value;
    double result = math.sin(angle);
    if (result.abs() < 1e-15) return 0;
    return result;
  }

  static double cos(double value, AngleMode mode) {
    double angle = mode == AngleMode.degrees ? value * math.pi / 180 : value;
    double result = math.cos(angle);
    if (result.abs() < 1e-15) return 0;
    return result;
  }

  static double tan(double value, AngleMode mode) {
    double angle = mode == AngleMode.degrees ? value * math.pi / 180 : value;
    return math.tan(angle);
  }

  static double asin(double value, AngleMode mode) {
    double result = math.asin(value);
    return mode == AngleMode.degrees ? result * 180 / math.pi : result;
  }

  static double acos(double value, AngleMode mode) {
    double result = math.acos(value);
    return mode == AngleMode.degrees ? result * 180 / math.pi : result;
  }

  static double atan(double value, AngleMode mode) {
    double result = math.atan(value);
    return mode == AngleMode.degrees ? result * 180 / math.pi : result;
  }

  static double ln(double value) => math.log(value);
  static double log10(double value) => math.log(value) / math.ln10;
  static double log2(double value) => math.log(value) / math.ln2;

  static double squareRoot(double value) {
    if (value < 0) throw ArgumentError('Cannot sqrt negative number');
    return math.sqrt(value);
  }

  static double cubeRoot(double value) {
    if (value < 0) return -math.pow(-value, 1.0 / 3.0).toDouble();
    return math.pow(value, 1.0 / 3.0).toDouble();
  }

  static double power(double base, double exponent) =>
      math.pow(base, exponent).toDouble();

  static String toBase(int value, int base) {
    if (base == 2) {
      String s = value.toRadixString(2).toUpperCase();
      if (s.length % 4 != 0) s = s.padLeft((s.length / 4).ceil() * 4, '0');
      return '0b$s';
    }
    if (base == 8) return '0o${value.toRadixString(8).toUpperCase()}';
    if (base == 16) {
      String s = value.toRadixString(16).toUpperCase();
      if (s.length % 2 != 0) s = s.padLeft(s.length + 1, '0');
      return '0x$s';
    }
    return value.toString();
  }

  static int parseBase(String value) {
    value = value.trim().toUpperCase();
    if (value.startsWith('0B')) return int.parse(value.substring(2), radix: 2);
    if (value.startsWith('0O')) return int.parse(value.substring(2), radix: 8);
    if (value.startsWith('0X')) return int.parse(value.substring(2), radix: 16);
    return int.parse(value);
  }

  static int bitwiseAnd(int a, int b) => a & b;
  static int bitwiseOr(int a, int b) => a | b;
  static int bitwiseXor(int a, int b) => a ^ b;
  static int bitwiseNot(int a) => ~a;
  static int leftShift(int a, int b) => a << b;
  static int rightShift(int a, int b) => a >> b;

  static String formatResult(double value, int precision) {
    if (value.isNaN) return 'Lỗi';
    if (value.isInfinite) return 'Vô cực';

    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    String formatted = value.toStringAsFixed(precision);
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }
}
