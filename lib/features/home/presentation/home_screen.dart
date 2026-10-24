import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:passly/common/widgets/loading_card_skeleton.dart';
import 'package:passly/common/widgets/passly_header.dart';
import 'package:passly/common/widgets/recent_encounter_card.dart';
import 'package:passly/core/constants/app_colors.dart';
import 'package:passly/core/constants/passly_tokens.dart';
import 'package:passly/features/home/domain/home_notifier.dart';
import 'package:passly/features/home/domain/recent_encounter.dart';
import 'package:passly/features/home/presentation/widgets/power_mode_toggle.dart';
import 'package:passly/core/utils/app_time.dart';

/// ホーム画面。
///
/// 「今日すれ違った人」だけを並べるシンプルな構成。
/// すれ違い数のレベル表示と最近の出会いカードは作り直しで削除した。
/// 右上には擬似フォアグラウンド ON/OFF を切り替える [PowerModeToggle] を配置。
///
/// ボトムナビは [MainScreen] 側で `PasslyBottomNav` として全タブ共通で描画する。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: PasslyBg.defaultBg,
      // PasslyHeader 自身が SafeArea を処理するため、ここでは wrap しない。
      // これでヘッダーの白背景がステータスバー / Dynamic Island 領域まで届く。
      body: Column(
        children: [
          const PasslyHeader(
            title: 'おかえり！',
            subtitle: '今日すれ違った人を見てみよう',
            trailing: [PowerModeToggle()],
          ),
          Expanded(
            child: homeState.when(
              data: (data) => _buildContent(context, ref, data),
              loading: () => _buildContent(
                context,
                ref,
                HomeState.empty(),
                isLoading: true,
              ),
              error: (_, _) => _buildErrorState(ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    HomeState data, {
    bool isLoading = false,
  }) {
    final todayEncounters = _filterToday(data.recentEncounters);

    return RefreshIndicator(
      color: PasslyBrand.primary,
      onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: PasslySpace.s16,
          right: PasslySpace.s16,
          top: PasslySpace.s24,
          bottom: 120,
        ),
        children: [
          const Text(
            '今日すれ違った人',
            style: TextStyle(
              fontFamily: PasslyFont.family,
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 24 / 20,
            ),
          ),
          const SizedBox(height: 13),
          if (isLoading)
            const LoadingCardsSkeleton()
          else
            ..._buildRecentEncounters(context, todayEncounters),
        ],
      ),
    );
  }

  List<Widget> _buildRecentEncounters(
    BuildContext context,
    List<RecentEncounter> items,
  ) {
    if (items.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: PasslySpace.s16),
          child: Text(
            '今日はまだ誰ともすれ違っていません',
            style: TextStyle(
              fontFamily: PasslyFont.family,
              color: PasslyText.secondary,
              fontSize: 14,
              fontWeight: PasslyFont.medium,
            ),
          ),
        ),
      ];
    }
    return [
      for (final e in items)
        Padding(
          padding: const EdgeInsets.only(bottom: PasslySpace.s4),
          child: RecentEncounterCard(
            avatarUrl: e.iconUrl.isNotEmpty ? e.iconUrl : null,
            name: e.name,
            time: _formatTime(e.metAt),
            location: e.eventName,
            onTap: () => context.push('/profile/${e.userId}'),
          ),
        ),
    ];
  }

  /// 日本時間で今日すれ違った人だけに絞る。
  List<RecentEncounter> _filterToday(List<RecentEncounter> items) {
    final today = AppTime.nowLocal();
    return items.where((e) {
      final local = AppTime.toAppLocal(e.metAt);
      return local.year == today.year &&
          local.month == today.month &&
          local.day == today.day;
    }).toList();
  }

  static String _formatTime(DateTime dt) {
    return AppTime.formatHHMM(dt);
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: PasslyText.secondary,
          ),
          const SizedBox(height: PasslySpace.s16),
          const Text(
            'データの取得に失敗しました',
            style: TextStyle(color: PasslyText.secondary, fontSize: 16),
          ),
          const SizedBox(height: PasslySpace.s16),
          ElevatedButton(
            onPressed: () => ref.read(homeNotifierProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PasslyBrand.primary,
            ),
            child: const Text('再試行', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
