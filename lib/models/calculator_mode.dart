enum CalculatorMode {
  basic,
  scientific,
  programmer,
}

extension CalculatorModeExtension on CalculatorMode {
  String get displayName {
    switch (this) {
      case CalculatorMode.basic:
        return 'Cơ bản';
      case CalculatorMode.scientific:
        return 'Khoa học';
      case CalculatorMode.programmer:
        return 'Lập trình';
    }
  }

  String get englishName {
    switch (this) {
      case CalculatorMode.basic:
        return 'Basic';
      case CalculatorMode.scientific:
        return 'Scientific';
      case CalculatorMode.programmer:
        return 'Programmer';
    }
  }
}
