import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/calculation_history.dart';
import '../providers/history_provider.dart';
import '../providers/calculator_provider.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Lịch sử',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (history.history.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Colors.red.shade400),
              onPressed: () => _showClearAllDialog(context),
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      body: history.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có lịch sử',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Các phép tính của bạn sẽ hiển thị ở đây',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.history.length,
              itemBuilder: (context, index) {
                final item = history.history[index];
                return _buildHistoryItem(context, item, index, isDark);
              },
            ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    CalculationHistory item,
    int index,
    bool isDark,
  ) {
    return Dismissible(
      key: Key('${item.timestamp.toIso8601String()}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<HistoryProvider>().removeEntry(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _useHistoryEntry(context, item),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkAccent.withOpacity(0.2)
                              : AppColors.lightAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.mode,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('HH:mm dd/MM').format(item.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.expression,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '= ${item.result}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _useHistoryEntry(BuildContext context, CalculationHistory item) {
    final calculator = context.read<CalculatorProvider>();
    try {
      double value = double.parse(item.result);
      if (value == value.roundToDouble() && value.abs() < 1e15) {
        calculator.onButtonPressed('C');
      }
      for (String char in item.result.split('')) {
        if (RegExp(r'^[0-9.]$').hasMatch(char)) {
          calculator.onButtonPressed(char);
        }
      }
      Navigator.pop(context);
    } catch (_) {}
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa toàn bộ lịch sử'),
        content: const Text('Hành động này không thể hoàn tác. Bạn có chắc không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
