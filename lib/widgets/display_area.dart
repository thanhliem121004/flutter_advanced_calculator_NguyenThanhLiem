import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DisplayArea extends StatelessWidget {
  final String expression;
  final String display;
  final String? errorMessage;
  final bool hasMemory;
  final String? angleModeLabel;
  final VoidCallback? onHistorySwipe;

  const DisplayArea({
    super.key,
    required this.expression,
    required this.display,
    this.errorMessage,
    this.hasMemory = false,
    this.angleModeLabel,
    this.onHistorySwipe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? Colors.white : Colors.black87;
    final dimColor = textColor.withOpacity(0.45);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
          onHistorySwipe?.call();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPadding,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDisplay),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasMemory || angleModeLabel != null)
                  Row(
                    children: [
                      if (hasMemory)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'M',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (angleModeLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkAccent.withOpacity(0.25)
                                : AppColors.lightAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkAccent.withOpacity(0.5)
                                  : AppColors.lightAccent.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            angleModeLabel!,
                            style: TextStyle(
                              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  const SizedBox.shrink(),
                if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (expression.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  expression,
                  style: AppFonts.historyText.copyWith(
                    color: dimColor,
                    fontSize: 20,
                  ),
                ),
              ),
            const SizedBox(height: 2),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  display,
                  key: ValueKey(display),
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamily,
                    fontWeight: FontWeight.w300,
                    color: errorMessage != null ? Colors.red.shade400 : textColor,
                    fontSize: display.length > 12 ? 38 : 52,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
