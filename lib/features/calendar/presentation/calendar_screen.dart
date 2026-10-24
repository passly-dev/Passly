import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syshack2026/common/widgets/loading_card_skeleton.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/features/calendar/domain/calendar_notifier.dart';
import 'package:syshack2026/features/calendar/presentation/widgets/encounter_bubble.dart';
import 'package:syshack2026/features/calendar/presentation/widgets/month_selector.dart';
import 'package:syshack2026/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:syshack2026/core/utils/app_time.dart';

/// カレンダー画面本体Widget
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = AppTime.nowLocal();
    _currentMonth = DateTime(now.year, now.month);

    // 初回データ取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarNotifierProvider.notifier).fetchMonthData(_currentMonth);
    });
  }

  void _onPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDay = null; // 月を変えたら選択解除
    });
    ref.read(calendarNotifierProvider.notifier).fetchMonthData(_currentMonth);
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDay = null;
    });
    ref.read(calendarNotifierProvider.notifier).fetchMonthData(_currentMonth);
  }

  void _onDaySelected(DateTime date) {
    final calendarState = ref.read(calendarNotifierProvider);
    final dayData = _findDayData(calendarState.encounterDays, date);

    setState(() {
      // すれ違いの有無に関わらず、タップした日付を選択状態にする
      _selectedDay = date;
    });

    // すれ違いがある日は詳細一覧画面へ遷移
    if (dayData != null) {
      final dateParam =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      context.push('/encounters/day/$dateParam');
    }
  }

  Map<String, dynamic>? _findDayData(
    Map<DateTime, Map<String, dynamic>> encounterDays,
    DateTime date,
  ) {
    for (final entry in encounterDays.entries) {
      if (entry.key.year == date.year &&
          entry.key.month == date.month &&
          entry.key.day == date.day) {
        return entry.value;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(height: 1, color: AppColors.divider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: 120,
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: const Text(
        'カレンダー',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final calendarState = ref.watch(calendarNotifierProvider);

    return Column(
      children: [
        // 吹き出しエリア
        _buildBubbleSection(calendarState),
        const SizedBox(height: 24),
        // 月切り替えとカレンダーグリッド
        MonthSelector(
          currentMonth: _currentMonth,
          onPreviousMonth: _onPreviousMonth,
          onNextMonth: _onNextMonth,
        ),
        const SizedBox(height: 8),
        if (calendarState.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingCardsSkeleton(),
          )
        else
          CalendarGrid(
            currentMonth: _currentMonth,
            selectedDay: _selectedDay,
            encounterDays: calendarState.encounterDays,
            onDaySelected: _onDaySelected,
          ),
      ],
    );
  }

  Widget _buildBubbleSection(CalendarState calendarState) {
    // 選択された日付がある場合
    if (_selectedDay != null) {
      final entry = calendarState.encounterDays.entries
          .cast<MapEntry<DateTime, Map<String, dynamic>>?>()
          .firstWhere(
            (e) =>
                e != null &&
                e.key.year == _selectedDay!.year &&
                e.key.month == _selectedDay!.month &&
                e.key.day == _selectedDay!.day,
            orElse: () => null,
          );

      if (entry != null) {
        final data = entry.value;
        final rawEventName = data['event'] as String?;
        final normalizedEventName = rawEventName?.trim() ?? '';
        return EncounterBubble(
          count: data['count'] as int,
          eventName: normalizedEventName.isNotEmpty
              ? normalizedEventName
              : 'イベントなし',
        );
      }

      // 選択日にすれ違いがない場合は 0 人を表示
      return const EncounterBubble(count: 0, eventName: 'イベントなし');
    }

    // 選択されていない場合は月の合計を表示
    return EncounterBubble(count: calendarState.monthTotal);
  }
}
