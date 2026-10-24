import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:syshack2026/common/widgets/passly_header.dart';
import 'package:syshack2026/common/widgets/loading_card_skeleton.dart';
import 'package:syshack2026/common/widgets/passly_icon.dart';
import 'package:syshack2026/common/widgets/recent_encounter_card.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/features/close_friend/domain/close_friend_list_notifier.dart';
import 'package:syshack2026/features/home/domain/home_notifier.dart';
import 'package:syshack2026/features/home/domain/recent_encounter.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/core/utils/app_time.dart';

/// 広場画面 (Figma node 1517:3046 準拠)。
///
/// 上から: PasslyHeader (「すれ違い一覧」+ 検索 + アバター) /
/// 「親しい人」セクション / 「今まですれ違った人」セクション。
///
/// 旧「友達一覧 / イベント一覧 / ランダム表示」のハンバーガーメニュー構成は
/// 撤去。イベント一覧はカレンダー画面で見られるため広場では扱わない。
///
/// バックエンド追加ゼロで既存プロバイダー流用:
/// - 親しい人: [closeFriendListProvider] (`GET /users/:id/close-friends`)
/// - 今まですれ違った人: [homeNotifierProvider] の `recentEncounters`
///   (`GET /users/:id/home` の recent_encounters を再利用)
class PlazaScreen extends ConsumerWidget {
  const PlazaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closeFriendsAsync = ref.watch(closeFriendListProvider);
    final homeState = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: PasslyBg.defaultBg,
      body: Column(
        children: [
          PasslyHeader(
            title: 'すれ違い一覧',
            subtitle: '友達検索も',
            trailing: [
              _HeaderSearchIcon(onTap: () => context.push('/plaza/search')),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              color: PasslyBrand.primary,
              onRefresh: () async {
                // CloseFriendListNotifier に refresh は無いので invalidate で
                // build() をやり直させて再フェッチする。
                ref.invalidate(closeFriendListProvider);
                await ref.read(homeNotifierProvider.notifier).refresh();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(15, 16, 15, 120),
                children: [
                  _CloseFriendsSection(async: closeFriendsAsync),
                  const SizedBox(height: PasslySpace.s16),
                  _PastEncountersSection(homeState: homeState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeading({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: PasslyFont.family,
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 19.2 / 16,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: PasslySpace.s8),
          Text(
            subtitle!,
            style: const TextStyle(
              fontFamily: PasslyFont.family,
              color: PasslyText.secondary,
              fontSize: 14,
              fontWeight: PasslyFont.medium,
              height: 16.8 / 14,
            ),
          ),
        ],
      ],
    );
  }
}

class _CloseFriendsSection extends StatelessWidget {
  final AsyncValue<List<UserModel>> async;
  const _CloseFriendsSection({required this.async});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: '親しい人'),
        const SizedBox(height: PasslySpace.s12),
        async.when(
          data: (users) => _list(context, users),
          loading: () => const LoadingCardsSkeleton(count: 2),
          error: (_, _) => const _EmptyMessage(text: '親しい人の取得に失敗しました'),
        ),
      ],
    );
  }

  Widget _list(BuildContext context, List<UserModel> users) {
    if (users.isEmpty) {
      return const _EmptyMessage(text: 'まだ親しい人がいません');
    }
    return Column(
      children: [
        for (int i = 0; i < users.length; i++) ...[
          if (i > 0) const SizedBox(height: PasslySpace.s4),
          RecentEncounterCard(
            avatarUrl: users[i].iconUrl.isNotEmpty ? users[i].iconUrl : null,
            name: users[i].name,
            time: _formatTime(users[i].lastEncounter?.metAt),
            location: users[i].lastEncounter?.eventName ?? '',
            affiliation: users[i].affiliation,
            onTap: () => context.push('/profile/${users[i].id}'),
          ),
        ],
      ],
    );
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return AppTime.formatHHMM(dt);
  }
}

class _PastEncountersSection extends StatelessWidget {
  final AsyncValue<HomeState> homeState;
  const _PastEncountersSection({required this.homeState});

  @override
  Widget build(BuildContext context) {
    return homeState.when(
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: '今まですれ違った人',
            subtitle: '${data.recentEncounters.length}人と出会いました',
          ),
          const SizedBox(height: PasslySpace.s12),
          _list(context, data.recentEncounters),
        ],
      ),
      loading: () => const LoadingCardsSkeleton(),
      error: (_, _) => const _EmptyMessage(text: 'すれ違い履歴の取得に失敗しました'),
    );
  }

  Widget _list(BuildContext context, List<RecentEncounter> encounters) {
    if (encounters.isEmpty) {
      return const _EmptyMessage(text: 'まだすれ違いがありません');
    }
    return Column(
      children: [
        for (int i = 0; i < encounters.length; i++) ...[
          if (i > 0) const SizedBox(height: PasslySpace.s4),
          RecentEncounterCard(
            avatarUrl: encounters[i].iconUrl.isNotEmpty
                ? encounters[i].iconUrl
                : null,
            name: encounters[i].name,
            time: _formatTime(encounters[i].metAt),
            location: encounters[i].eventName,
            onTap: () => context.push('/profile/${encounters[i].userId}'),
          ),
        ],
      ],
    );
  }

  static String _formatTime(DateTime dt) {
    return AppTime.formatHHMM(dt);
  }
}

class _EmptyMessage extends StatelessWidget {
  final String text;
  const _EmptyMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: PasslyFont.family,
          color: PasslyText.secondary,
          fontSize: 14,
          fontWeight: PasslyFont.medium,
        ),
      ),
    );
  }
}

/// 40x40 の検索アイコン。カレンダーヘッダーと同じ [PasslyIcons.search] を使い、
/// アプリ全体でアイコンの見た目 / タップサイズを統一する。
class _HeaderSearchIcon extends StatelessWidget {
  final VoidCallback onTap;
  const _HeaderSearchIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: PasslyIcon(
            asset: PasslyIcons.search,
            size: 30,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
