import 'calculator_mode.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Sáng';
      case AppThemeMode.dark:
        return 'Tối';
      case AppThemeMode.system:
        return 'Hệ thống';
    }
  }
}

enum AngleMode {
  degrees,
  radians,
}

extension AngleModeExtension on AngleMode {
  String get displayName {
    switch (this) {
      case AngleMode.degrees:
        return 'Độ (DEG)';
      case AngleMode.radians:
        return 'Radian (RAD)';
    }
  }
}

class CalculatorSettings {
  final AppThemeMode themeMode;
  final int decimalPrecision;
  final AngleMode angleMode;
  final bool hapticFeedback;
  final bool soundEffects;
  final int historySize;
  final CalculatorMode defaultMode;

  const CalculatorSettings({
    this.themeMode = AppThemeMode.dark,
    this.decimalPrecision = 10,
    this.angleMode = AngleMode.degrees,
    this.hapticFeedback = true,
    this.soundEffects = false,
    this.historySize = 50,
    this.defaultMode = CalculatorMode.basic,
  });

  CalculatorSettings copyWith({
    AppThemeMode? themeMode,
    int? decimalPrecision,
    AngleMode? angleMode,
    bool? hapticFeedback,
    bool? soundEffects,
    int? historySize,
    CalculatorMode? defaultMode,
  }) {
    return CalculatorSettings(
      themeMode: themeMode ?? this.themeMode,
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      angleMode: angleMode ?? this.angleMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      historySize: historySize ?? this.historySize,
      defaultMode: defaultMode ?? this.defaultMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.index,
        'decimalPrecision': decimalPrecision,
        'angleMode': angleMode.index,
        'hapticFeedback': hapticFeedback,
        'soundEffects': soundEffects,
        'historySize': historySize,
        'defaultMode': defaultMode.index,
      };

  factory CalculatorSettings.fromJson(Map<String, dynamic> json) {
    return CalculatorSettings(
      themeMode: AppThemeMode.values[json['themeMode'] as int? ?? 1],
      decimalPrecision: json['decimalPrecision'] as int? ?? 10,
      angleMode: AngleMode.values[json['angleMode'] as int? ?? 0],
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      soundEffects: json['soundEffects'] as bool? ?? false,
      historySize: json['historySize'] as int? ?? 50,
      defaultMode:
          CalculatorMode.values[json['defaultMode'] as int? ?? 0],
    );
  }
}
