import 'package:flutter/material.dart';
import 'package:syshack2026/common/widgets/press_feedback.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

// 修正: 不要なコメントの削除とコードの最小化
class TabSwitchButton extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const TabSwitchButton({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              '友達一覧',
              selectedIndex == 0,
              () => onTabChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              'イベント一覧',
              selectedIndex == 1,
              () => onTabChanged(1),
            ),
          ),
        ],
      ),
    );
  }

  // 修正: 引数をシンプルに整理
  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: PressFeedback(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? AppColors.backgroundWhite
                  : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
