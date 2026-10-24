import 'package:flutter/material.dart';
import 'package:syshack2026/common/widgets/press_feedback.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

/// 表示月を切り替えるヘッダーWidget
class MonthSelector extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthSelector({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左: ＜ 先月
          GestureDetector(
            onTap: onPreviousMonth,
            child: const PressFeedback(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '＜ 先月',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          // 中央: 年月
          Text(
            '${currentMonth.year}年 ${currentMonth.month}月',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // 右: 次月 ＞
          GestureDetector(
            onTap: onNextMonth,
            child: const PressFeedback(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '次月 ＞',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
