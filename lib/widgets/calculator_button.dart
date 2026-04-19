import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

enum CalcButtonType {
  number,
  operator,
  function,
  equals,
  clear,
  memory,
  parenthesis,
  accent,
}

class CalculatorButton extends StatefulWidget {
  final String label;
  final String? subLabel;
  final CalcButtonType type;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final int flex;
  final double? fontSize;

  const CalculatorButton({
    super.key,
    required this.label,
    this.subLabel,
    required this.type,
    required this.onPressed,
    this.onLongPress,
    this.flex = 1,
    this.fontSize,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDimensions.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  Color _getBackgroundColor(bool isDark) {
    switch (widget.type) {
      case CalcButtonType.number:
        return isDark ? AppColors.numberButtonDark : AppColors.numberButtonLight;
      case CalcButtonType.operator:
        return isDark ? AppColors.operatorButtonDark : AppColors.operatorButtonLight;
      case CalcButtonType.function:
        return isDark ? AppColors.functionButtonDark : AppColors.functionButtonLight;
      case CalcButtonType.equals:
        return isDark ? AppColors.equalsButtonDark : AppColors.equalsButtonLight;
      case CalcButtonType.clear:
        return isDark ? AppColors.clearButtonDark : AppColors.clearButtonLight;
      case CalcButtonType.memory:
        return isDark ? AppColors.functionButtonDark : AppColors.functionButtonLight;
      case CalcButtonType.parenthesis:
        return isDark ? AppColors.functionButtonDark : AppColors.functionButtonLight;
      case CalcButtonType.accent:
        return isDark ? AppColors.darkAccent : AppColors.lightAccent;
    }
  }

  Color _getTextColor(bool isDark) {
    switch (widget.type) {
      case CalcButtonType.number:
        return isDark ? Colors.white : Colors.black87;
      case CalcButtonType.operator:
        return isDark ? AppColors.darkAccent : AppColors.lightAccent;
      case CalcButtonType.function:
        return isDark ? Colors.white70 : Colors.black87;
      case CalcButtonType.equals:
        return Colors.white;
      case CalcButtonType.clear:
        return Colors.white;
      case CalcButtonType.memory:
        return isDark ? AppColors.darkAccent : AppColors.lightAccent;
      case CalcButtonType.parenthesis:
        return isDark ? AppColors.darkAccent : AppColors.lightAccent;
      case CalcButtonType.accent:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _getBackgroundColor(isDark);
    final fgColor = _getTextColor(isDark);
    final fontSize = widget.fontSize ?? 26.0;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  gradient: widget.type == CalcButtonType.equals
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF4ECDC4), const Color(0xFF3DBDB5)]
                              : [const Color(0xFFFF6B6B), const Color(0xFFFF5252)],
                        )
                      : null,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: widget.subLabel != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.subLabel!,
                                  style: TextStyle(
                                    fontSize: fontSize * 0.45,
                                    color: fgColor.withOpacity(0.55),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  widget.label,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    color: fgColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              widget.label,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: fgColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
