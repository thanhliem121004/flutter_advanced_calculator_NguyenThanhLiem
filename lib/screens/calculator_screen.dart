import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/display_area.dart';
import '../widgets/mode_selector.dart';
import '../widgets/button_grid.dart';
import '../utils/constants.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    final calculator = context.watch<CalculatorProvider>();
    final history = context.watch<HistoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 4),
                        DisplayArea(
                          expression: calculator.expression,
                          display: calculator.display,
                          errorMessage: calculator.errorMessage,
                          hasMemory: calculator.hasMemory,
                          angleModeLabel: calculator.mode == CalculatorMode.scientific
                              ? (calculator.angleMode == AngleMode.degrees ? 'DEG' : 'RAD')
                              : null,
                          onHistorySwipe: () => _openHistory(context),
                        ),
                        const SizedBox(height: 8),
                        _buildMemoryIndicator(calculator),
                        if (calculator.mode == CalculatorMode.scientific)
                          _buildScientificIndicator(calculator),
                        if (calculator.mode == CalculatorMode.programmer)
                          _buildProgrammerIndicator(calculator),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ButtonGrid(
                          mode: calculator.mode,
                          angleMode: calculator.angleMode,
                          isSecondFunction: calculator.isSecondFunction,
                          onButtonPressed: (value) {
                            calculator.onButtonPressed(value);
                            if (value == '=') {
                              final expr = calculator.getFullExpression();
                              if (expr.isNotEmpty && calculator.display != 'Lỗi') {
                                history.addEntry(
                                  expr,
                                  calculator.display,
                                  calculator.mode,
                                );
                              }
                            }
                          },
                          onClearHistory: () => _showClearHistoryDialog(context),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final calculator = context.watch<CalculatorProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () => _openHistory(context),
            tooltip: 'Lịch sử',
          ),
          const SizedBox(width: 8),
          ModeSelector(
            selectedMode: calculator.mode,
            onModeChanged: (mode) {
              calculator.setMode(mode);
              calculator.saveSettings();
            },
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () => _openSettings(context),
            tooltip: 'Cài đặt',
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryIndicator(CalculatorProvider calculator) {
    if (!calculator.hasMemory) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkAccent.withOpacity(0.2)
            : AppColors.lightAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.memory,
            size: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkAccent
                : AppColors.lightAccent,
          ),
          const SizedBox(width: 4),
          Text(
            'M: ${calculator.memory}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkAccent
                  : AppColors.lightAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificIndicator(CalculatorProvider calculator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: calculator.isSecondFunction
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkAccent
                      : AppColors.lightAccent)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkAccent
                    : AppColors.lightAccent,
              ),
            ),
            child: Text(
              '2nd',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: calculator.isSecondFunction
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkAccent
                        : AppColors.lightAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgrammerIndicator(CalculatorProvider calculator) {
    String baseName;
    switch (calculator.base) {
      case 2:
        baseName = 'BIN';
        break;
      case 8:
        baseName = 'OCT';
        break;
      case 10:
        baseName = 'DEC';
        break;
      case 16:
        baseName = 'HEX';
        break;
      default:
        baseName = 'DEC';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkAccent.withOpacity(0.2)
                  : AppColors.lightAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Cơ số: $baseName',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkAccent
                    : AppColors.lightAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử tính toán không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa lịch sử'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
