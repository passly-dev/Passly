import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/common/widgets/loading_card_skeleton.dart';
import 'package:go_router/go_router.dart';

import 'package:syshack2026/common/widgets/passly_header.dart';
import 'package:syshack2026/common/widgets/recent_encounter_card.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/features/close_friend/domain/close_friend_list_notifier.dart';
import 'package:syshack2026/features/user/data/tech_tag_catalog.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/core/utils/app_time.dart';

/// 広場ヘッダーの検索アイコンから開く「友達検索」画面。
///
/// 検索対象は現状 `closeFriendListProvider` の親しい人リスト。
/// バックエンドに「ユーザー全文検索」API が無いため、当面はクライアント側で
/// 名前 (name) と技術タグ (tech_stack) を部分一致で絞り込む。
///
/// クエリはスペース / カンマ / スラッシュで区切って複数キーワードを受け付ける
/// (AND 条件)。1 キーワードは name / tag のどちらに当てはまっても OK (OR)。
class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final next = _controller.text.trim();
      if (next != _query) setState(() => _query = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final closeFriendsAsync = ref.watch(closeFriendListProvider);

    return Scaffold(
      backgroundColor: PasslyBg.defaultBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasslyHeader.search(
            onBack: () {
              if (context.canPop()) context.pop();
            },
            controller: _controller,
            hintText: '名前 / タグで検索',
          ),
          Expanded(
            child: closeFriendsAsync.when(
              data: (users) => _buildResults(users),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LoadingCardsSkeleton(),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '親しい人の取得に失敗しました\n$err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: PasslyFont.family,
                      color: PasslyText.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<UserModel> users) {
    final matches = _filter(users, _query);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 24),
      children: [
        Text(
          _query.isEmpty
              ? '親しい人 ${users.length} 人'
              : '「$_query」の検索結果 ${matches.length} 人',
          style: const TextStyle(
            fontFamily: PasslyFont.family,
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 19.2 / 16,
          ),
        ),
        const SizedBox(height: PasslySpace.s12),
        if (matches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              _query.isEmpty ? 'まだ親しい人がいません' : '該当する人はいません',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: PasslyFont.family,
                color: PasslyText.secondary,
                fontSize: 14,
                fontWeight: PasslyFont.medium,
              ),
            ),
          )
        else
          for (int i = 0; i < matches.length; i++) ...[
            if (i > 0) const SizedBox(height: PasslySpace.s4),
            RecentEncounterCard(
              avatarUrl: matches[i].iconUrl.isNotEmpty
                  ? matches[i].iconUrl
                  : null,
              name: matches[i].name,
              time: _formatTime(matches[i].lastEncounter?.metAt),
              location: matches[i].lastEncounter?.eventName ?? '',
              affiliation: matches[i].affiliation,
              onTap: () => context.push('/profile/${matches[i].id}'),
            ),
          ],
      ],
    );
  }

  /// 名前 (name) と技術タグ (tech_stack) 部分一致 (AND: 空白等区切りの全語) で絞り込む。
  /// 1 語は name / tag のどちらかにヒットすればマッチ扱い (OR)。
  List<UserModel> _filter(List<UserModel> users, String rawQuery) {
    if (rawQuery.isEmpty) return users;
    final keywords = rawQuery
        .split(RegExp(r'[,、/／・\s]+'))
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
    if (keywords.isEmpty) return users;

    return users.where((u) {
      final name = u.name.toLowerCase();
      final tags = u.techStack
          .split(RegExp(r'[,、/／・\s]+'))
          .map((s) => TechTagCatalog.normalize(s.trim()).toLowerCase())
          .where((s) => s.isNotEmpty)
          .toList();
      return keywords.every((kw) {
        if (name.contains(kw)) return true;
        return tags.any((t) => t.contains(kw));
      });
    }).toList();
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return AppTime.formatHHMM(dt);
  }
}
