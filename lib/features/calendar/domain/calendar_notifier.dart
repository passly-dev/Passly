import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/features/calendar/data/calendar_repository.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/core/utils/app_time.dart';

/// カレンダー画面のデータ状態
class CalendarState {
  /// 日付ごとのすれ違いデータ（キー: DateTime、値: {count, event, users}）
  final Map<DateTime, Map<String, dynamic>> encounterDays;

  /// 月の合計すれ違い数
  final int monthTotal;

  /// ロード中かどうか
  final bool isLoading;

  const CalendarState({
    required this.encounterDays,
    required this.monthTotal,
    this.isLoading = false,
  });

  factory CalendarState.empty() =>
      const CalendarState(encounterDays: {}, monthTotal: 0);

  CalendarState copyWith({
    Map<DateTime, Map<String, dynamic>>? encounterDays,
    int? monthTotal,
    bool? isLoading,
  }) {
    return CalendarState(
      encounterDays: encounterDays ?? this.encounterDays,
      monthTotal: monthTotal ?? this.monthTotal,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// カレンダー画面のデータを管理するプロバイダー
final calendarNotifierProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);

/// カレンダー画面のデータ管理を行うNotifier
class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    return CalendarState.empty();
  }

  /// 指定月のデータを取得。
  ///
  /// 日別ループは Repository 側の fetchMonthlyCalendar に集約したため、
  /// この Notifier は取得後のマージだけを担当する。
  Future<void> fetchMonthData(DateTime month) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(calendarRepositoryProvider);

      // 日別データとイベント一覧を並列取得
      final results = await Future.wait([
        repo.fetchMonthlyCalendar(userId: user.id, month: month),
        repo.fetchMonthEvents(month),
      ]);
      final daily = results[0] as Map<DateTime, Map<String, dynamic>>;
      final monthEvents = results[1] as List<Map<String, dynamic>>;

      final newEncounterDays = Map<DateTime, Map<String, dynamic>>.from(
        state.encounterDays,
      )..addAll(daily);

      int monthTotal = 0;
      for (final entry in daily.entries) {
        monthTotal += (entry.value['count'] as int?) ?? 0;
      }

      // 参加予定イベントを日付にマージ（イベントだけ登録された日を作る）
      for (final event in monthEvents) {
        final startAtUtc = DateTime.tryParse(
          event['start_at']?.toString() ?? '',
        );
        if (startAtUtc == null) continue;
        final startAt = AppTime.toAppLocal(startAtUtc);
        final date = DateTime(startAt.year, startAt.month, startAt.day);

        final existing = newEncounterDays[date] ?? const <String, dynamic>{};
        final merged = Map<String, dynamic>.from(existing);

        merged['event'] = merged['event'] ?? event['name']?.toString() ?? '';
        merged['event_location'] =
            event['location']?.toString() ??
            merged['event_location']?.toString() ??
            '';
        merged['event_url'] =
            event['event_url']?.toString() ??
            merged['event_url']?.toString() ??
            '';
        merged['event_id'] = merged['event_id'] ?? event['id'];
        merged['count'] = merged['count'] ?? 0;
        merged['users'] = merged['users'] ?? const <Map<String, dynamic>>[];

        newEncounterDays[date] = merged;
      }

      state = CalendarState(
        encounterDays: newEncounterDays,
        monthTotal: monthTotal,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 特定日のデータを取得
  Map<String, dynamic>? getDayData(DateTime date) {
    return state.encounterDays.entries
        .cast<MapEntry<DateTime, Map<String, dynamic>>?>()
        .firstWhere(
          (e) =>
              e != null &&
              e.key.year == date.year &&
              e.key.month == date.month &&
              e.key.day == date.day,
          orElse: () => null,
        )
        ?.value;
  }
}
