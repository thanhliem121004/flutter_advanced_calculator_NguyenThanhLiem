import 'package:flutter/material.dart';
import '../models/calculator_mode.dart';
import '../utils/constants.dart';

class ModeSelector extends StatelessWidget {
  final CalculatorMode selectedMode;
  final ValueChanged<CalculatorMode> onModeChanged;

  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CalculatorMode.values.map((mode) {
          final isSelected = mode == selectedMode;
          final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

          return GestureDetector(
            onTap: () => onModeChanged(mode),
            child: AnimatedContainer(
              duration: AppDimensions.modeTransitionDuration,
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                mode.displayName,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white54 : Colors.black45),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
