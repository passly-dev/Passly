import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:syshack2026/common/widgets/person_list_view.dart';
import 'package:syshack2026/features/calendar/domain/calendar_notifier.dart';

/// 指定日のすれ違い相手一覧画面。
///
/// カレンダー画面の日付タップから遷移。データは calendarNotifierProvider の
/// 該当日エントリから引く。時刻情報は現状データにないため表示しない
/// （バックエンド側で encounters.created_at を返すようになったら差し替え）。
class DailyEncounterListScreen extends ConsumerWidget {
  final DateTime date;

  const DailyEncounterListScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final dayData = _findDayData(calendarState.encounterDays);

    final items = _extractItems(dayData);
    final count = (dayData?['count'] as int?) ?? items.length;
    final eventName = (dayData?['event'] as String?)?.trim() ?? '';

    return PersonListView(
      headerTitle: 'その日に出会った人',
      headerSubtitle: '気になる人を見つけよう！',
      sectionTitle: '${date.month}月${date.day}日の出会い',
      sectionSubtitle: eventName.isEmpty
          ? '$count人と出会いました'
          : '$count人と出会いました · $eventName',
      itemsAsync: calendarState.isLoading
          ? const AsyncValue.loading()
          : AsyncValue.data(items),
      emptyMessage: 'この日はまだ出会いがありません',
      onItemTap: (userId) => context.push('/profile/$userId'),
    );
  }

  Map<String, dynamic>? _findDayData(
    Map<DateTime, Map<String, dynamic>> encounterDays,
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

  List<PersonListItem> _extractItems(Map<String, dynamic>? dayData) {
    if (dayData == null) return const [];
    final rawUsers = dayData['users'];
    if (rawUsers is! List) return const [];

    final eventName = (dayData['event'] as String?)?.trim() ?? '';

    return rawUsers
        .whereType<Map>()
        .map((raw) {
          final map = Map<String, dynamic>.from(raw);
          return PersonListItem(
            userId: map['id']?.toString() ?? '',
            name: map['name']?.toString() ?? '',
            iconUrl: map['iconUrl']?.toString() ?? '',
            // TODO(passly): API が個別の encounter 時刻を返すようになったら埋める
            timeLabel: null,
            eventLabel: eventName.isEmpty ? null : eventName,
          );
        })
        .where((item) => item.userId.isNotEmpty)
        .toList();
  }
}
