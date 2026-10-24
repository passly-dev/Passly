import 'package:flutter/material.dart';

import 'package:syshack2026/common/widgets/passly_icon.dart';
import 'package:syshack2026/common/widgets/week_day_pill.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';

/// Figma node 1196:1352 「カレンダーカード」。
///
/// 月ナビ (< YYYY年M月 > 月表示はこちら) + 週の 7 日ピル (日曜起点)。
///
/// - [selectedDate] の月がタイトルに表示される
/// - 前後 chevron は月単位の移動 ([onPrevMonth]/[onNextMonth])
/// - 曜日ピルタップで [onSelectDate] が発火
/// - 「月表示はこちら」タップで [onOpenMonthView] (null なら非タップ)
class WeekCalendarCard extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback? onOpenMonthView;

  /// 週の起点。true=日曜始まり (Figma 準拠)、false=月曜始まり。
  final bool sundayStart;

  const WeekCalendarCard({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onPrevMonth,
    required this.onNextMonth,
    this.onOpenMonthView,
    this.sundayStart = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _MonthNavRow(
          month: selectedDate,
          onPrev: onPrevMonth,
          onNext: onNextMonth,
          onOpenMonthView: onOpenMonthView,
        ),
        const SizedBox(height: PasslySpace.s8),
        _WeekRow(
          selectedDate: selectedDate,
          onSelect: onSelectDate,
          sundayStart: sundayStart,
        ),
      ],
    );
  }
}

class _MonthNavRow extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback? onOpenMonthView;

  const _MonthNavRow({
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.onOpenMonthView,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ChevronButton(onTap: onPrev, flipHorizontal: false),
        const SizedBox(width: 4),
        Text(
          '${month.year}年${month.month}月',
          style: const TextStyle(
            fontFamily: PasslyFont.family,
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 24 / 20,
          ),
        ),
        const SizedBox(width: 4),
        _ChevronButton(onTap: onNext, flipHorizontal: true),
        const SizedBox(width: 4),
        if (onOpenMonthView != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onOpenMonthView,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                '月表示はこちら',
                style: TextStyle(
                  fontFamily: PasslyFont.family,
                  color: PasslyState.info,
                  fontSize: 12,
                  fontWeight: PasslyFont.medium,
                  height: 14.4 / 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Figma 1300:1138 準拠: 22.84x22.84 の丸型タップ領域に 18px chevron。
class _ChevronButton extends StatelessWidget {
  final VoidCallback onTap;

  /// true にすると右向きシェブロン (>) として表示する。
  final bool flipHorizontal;

  const _ChevronButton({required this.onTap, required this.flipHorizontal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 23,
        height: 23,
        child: Center(
          child: PasslyIcon(
            asset: PasslyIcons.chevron,
            size: 18,
            color: AppColors.textPrimary,
            flipHorizontal: flipHorizontal,
          ),
        ),
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;
  final bool sundayStart;

  const _WeekRow({
    required this.selectedDate,
    required this.onSelect,
    required this.sundayStart,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart = _startOfWeek(selectedDate, sundayStart: sundayStart);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final date = weekStart.add(Duration(days: i));
        return WeekDayPill(
          date: date,
          isSelected: _isSameDay(date, selectedDate),
          onTap: () => onSelect(date),
        );
      }),
    );
  }

  /// 週の起点日を計算する。
  /// DateTime.weekday は 1(月)〜7(日)。
  /// - sundayStart=true: 日曜(7)を起点にする
  /// - sundayStart=false: 月曜(1)を起点にする
  DateTime _startOfWeek(DateTime date, {required bool sundayStart}) {
    if (sundayStart) {
      // weekday=7 (日) → delta=0、weekday=1 (月) → delta=1、weekday=6 (土) → delta=6
      final delta = date.weekday % 7;
      return DateTime(date.year, date.month, date.day - delta);
    }
    final delta = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - delta);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
