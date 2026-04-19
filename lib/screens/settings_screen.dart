import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/history_provider.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late CalculatorSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = context.read<StorageService>();
    final loaded = await storage.loadSettings();
    setState(() {
      _settings = loaded;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final storage = context.read<StorageService>();
    await storage.saveSettings(_settings);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Cài đặt',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Giao diện', isDark),
                _buildSettingsCard([
                  _buildThemeSelector(isDark),
                  _buildDivider(),
                  _buildDecimalPrecision(isDark),
                  _buildDivider(),
                  _buildAngleMode(isDark),
                  _buildDivider(),
                  _buildDefaultMode(isDark),
                ], isDark),
                const SizedBox(height: 24),
                _buildSectionTitle('Cảm giác', isDark),
                _buildSettingsCard([
                  _buildSwitchTile(
                    'Rung khi nhấn',
                    'Haptic feedback khi nhấn nút',
                    _settings.hapticFeedback,
                    (value) {
                      setState(() {
                        _settings = _settings.copyWith(hapticFeedback: value);
                      });
                      _saveSettings();
                    },
                    isDark,
                  ),
                ], isDark),
                const SizedBox(height: 24),
                _buildSectionTitle('Lịch sử', isDark),
                _buildSettingsCard([
                  _buildHistorySize(isDark),
                  _buildDivider(),
                  _buildClearHistory(isDark),
                ], isDark),
                const SizedBox(height: 24),
                _buildSectionTitle('Giới thiệu', isDark),
                _buildSettingsCard([
                  _buildInfoTile('Ứng dụng', 'Máy tính nâng cao', isDark),
                  _buildDivider(),
                  _buildInfoTile('Phiên bản', '1.0.0', isDark),
                  _buildDivider(),
                  _buildInfoTile('Sinh viên', 'Nguyễn Thanh Liêm', isDark),
                  _buildDivider(),
                  _buildInfoTile('MSSV', '2224802010267', isDark),
                ], isDark),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, bool isDark) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildThemeSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chủ đề',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chọn giao diện sáng hoặc tối',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: AppThemeMode.values.map((mode) {
              final isSelected = mode == _settings.themeMode;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _settings = _settings.copyWith(themeMode: mode);
                    });
                    context.read<ThemeProvider>().setThemeMode(mode);
                    _saveSettings();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                          : (isDark ? AppColors.darkSecondary : AppColors.lightSecondary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        mode.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDecimalPrecision(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Độ chính xác thập phân',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [2, 4, 6, 8, 10].map((val) {
              final isSelected = val == _settings.decimalPrecision;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _settings = _settings.copyWith(decimalPrecision: val);
                    });
                    context.read<CalculatorProvider>().setPrecision(val);
                    _saveSettings();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? Colors.white24 : Colors.black26),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$val',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAngleMode(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn vị góc',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _settings.angleMode == AngleMode.degrees ? 'Độ (DEG)' : 'Radian (RAD)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          SegmentedButton<AngleMode>(
            segments: [
              ButtonSegment(value: AngleMode.degrees, label: Text('DEG', style: TextStyle(fontSize: 12))),
              ButtonSegment(value: AngleMode.radians, label: Text('RAD', style: TextStyle(fontSize: 12))),
            ],
            selected: {_settings.angleMode},
            onSelectionChanged: (selection) {
              setState(() {
                _settings = _settings.copyWith(angleMode: selection.first);
              });
              context.read<CalculatorProvider>().setAngleMode(selection.first);
              _saveSettings();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return isDark ? AppColors.darkAccent : AppColors.lightAccent;
                }
                return Colors.transparent;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultMode(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chế độ mặc định',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chế độ khởi động khi mở app',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<CalculatorMode>(
            value: _settings.defaultMode,
            dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            underline: const SizedBox(),
            items: CalculatorMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(
                  mode.displayName,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (mode) {
              if (mode != null) {
                setState(() {
                  _settings = _settings.copyWith(defaultMode: mode);
                });
                context.read<CalculatorProvider>().setMode(mode);
                _saveSettings();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySize(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số lượng lịch sử',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_settings.historySize} phép tính',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<int>(
            value: _settings.historySize,
            dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            underline: const SizedBox(),
            items: [25, 50, 100].map((val) {
              return DropdownMenuItem(
                value: val,
                child: Text(
                  '$val',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _settings = _settings.copyWith(historySize: val);
                });
                context.read<HistoryProvider>().setMaxHistory(val);
                _saveSettings();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClearHistory(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showClearHistoryDialog(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
              const SizedBox(width: 12),
              Text(
                'Xóa toàn bộ lịch sử',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
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
