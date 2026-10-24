import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/features/calendar/presentation/widgets/calendar_day_cell.dart';
import 'package:syshack2026/core/utils/app_time.dart';

/// 曜日ヘッダーと日付セルで構成されるカレンダーグリッド
class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDay;
  final Map<DateTime, Map<String, dynamic>> encounterDays;
  final ValueChanged<DateTime> onDaySelected;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDay,
    required this.encounterDays,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildWeekdayHeader(),
          const SizedBox(height: 8),
          _buildDaysGrid(),
        ],
      ),
    );
  }

  /// 曜日ヘッダー（日〜土）
  Widget _buildWeekdayHeader() {
    final weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    final colors = [
      AppColors.calendarSunday, // 日
      AppColors.textSecondary, // 月
      AppColors.textSecondary, // 火
      AppColors.textSecondary, // 水
      AppColors.textSecondary, // 木
      AppColors.textSecondary, // 金
      AppColors.calendarSaturday, // 土
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        return Expanded(
          child: Center(
            child: Text(
              weekdays[index],
              style: TextStyle(
                color: colors[index],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 日付セルのグリッド（7列 x 最大6行）
  Widget _buildDaysGrid() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    // 日曜は DateTime.sunday (7) なので 7の余りを取ると 0 になる
    final emptyCellsBefore = firstDay.weekday % 7;
    final totalCells = emptyCellsBefore + daysInMonth;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        // 月の開始日より前は空のセルを表示
        if (index < emptyCellsBefore) {
          return const SizedBox.shrink();
        }

        final day = index - emptyCellsBefore + 1;
        final date = DateTime(currentMonth.year, currentMonth.month, day);
        final now = AppTime.nowLocal();
        final isToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        // すれ違いデータの確認。時刻部分を無視して年月日で一致判定
        final encounterEntry = encounterDays.entries
            .cast<MapEntry<DateTime, Map<String, dynamic>>?>()
            .firstWhere(
              (e) =>
                  e != null &&
                  e.key.year == date.year &&
                  e.key.month == date.month &&
                  e.key.day == date.day,
              orElse: () => null,
            );
        final count = (encounterEntry?.value['count'] as int?) ?? 0;
        final hasEncounter = count > 0;
        final eventName = encounterEntry?.value['event'] as String?;
        final hasEvent = eventName != null && eventName.isNotEmpty;

        return CalendarDayCell(
          date: date,
          isToday: isToday,
          hasEncounter: hasEncounter,
          hasEvent: hasEvent,
          onTap: () => onDaySelected(date),
        );
      },
    );
  }
}
