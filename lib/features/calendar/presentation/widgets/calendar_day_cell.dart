import 'package:flutter/material.dart';
import 'package:syshack2026/common/widgets/press_feedback.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

/// カレンダーの各日付セルを描画するWidget
class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool hasEncounter;
  final bool hasEvent;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.hasEncounter,
    required this.hasEvent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: PressFeedback(
        child: Container(
          alignment: Alignment.center,
          child: _buildCellContent(),
        ),
      ),
    );
  }

  Widget _buildCellContent() {
    // すれ違いがある日は緑の丸背景。イベントがあれば右上に印を表示。
    if (hasEncounter) {
      return SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: const TextStyle(
                    color: AppColors.backgroundWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (hasEvent)
              const Positioned(top: 1, right: 1, child: _EventDot()),
          ],
        ),
      );
    }

    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(alignment: Alignment.center, child: _buildDayNumber()),
          if (hasEvent) const Positioned(top: 1, right: 1, child: _EventDot()),
        ],
      ),
    );
  }

  Widget _buildDayNumber() {
    // 今日の場合: 緑の枠線 + 緑文字（太字）
    if (isToday) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 通常の日付: 黒文字
    return Text(
      '${date.day}',
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
    );
  }
}

class _EventDot extends StatelessWidget {
  const _EventDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1),
      ),
    );
  }
}
