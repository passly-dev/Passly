import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:syshack2026/common/widgets/person_list_view.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/features/close_friend/domain/close_friend_list_notifier.dart';
import 'package:syshack2026/core/utils/app_time.dart';

/// 自分の「親しい友達」一覧画面。
///
/// 既存の closeFriendListProvider を使用。UserModel.lastEncounter が
/// あれば時刻とイベントを 1 件のカードに表示する。
class CloseFriendListScreen extends ConsumerWidget {
  const CloseFriendListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(closeFriendListProvider);
    final count = listAsync.asData?.value.length ?? 0;

    final itemsAsync = listAsync.whenData(
      (users) => users.map(_toItem).toList(),
    );

    return PersonListView(
      headerTitle: '親しい友達 一覧',
      headerSubtitle: '大事な人たちをまとめて見よう！',
      sectionTitle: '親しい友達',
      sectionSubtitle: '$count人',
      itemsAsync: itemsAsync,
      emptyMessage: 'まだ親しい友達がいません',
      onItemTap: (userId) => context.push('/profile/$userId'),
    );
  }

  PersonListItem _toItem(UserModel user) {
    final last = user.lastEncounter;
    String? timeLabel;
    String? eventLabel;
    if (last != null) {
      final local = AppTime.toAppLocal(last.metAt);
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      timeLabel = '$hour:$minute';
      eventLabel = last.eventName.isEmpty ? null : last.eventName;
    }

    return PersonListItem(
      userId: user.id,
      name: user.name,
      iconUrl: user.iconUrl,
      timeLabel: timeLabel,
      eventLabel: eventLabel,
    );
  }
}
