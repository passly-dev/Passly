import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/features/home/data/home_repository.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/home/domain/recent_encounter.dart';

/// ホーム画面のデータ状態
class HomeState {
  final int totalEncounters;
  final int todayEncounters;
  final List<Map<String, dynamic>> unconfirmed;
  final List<Map<String, dynamic>> randomThree;

  /// 「最近の出会い」セクション（バックエンド: recent_encounters）。
  /// サーバー未実装の間は常に空配列としてパースされる。
  final List<RecentEncounter> recentEncounters;

  const HomeState({
    required this.totalEncounters,
    required this.todayEncounters,
    required this.unconfirmed,
    required this.randomThree,
    this.recentEncounters = const [],
  });

  factory HomeState.empty() => const HomeState(
    totalEncounters: 0,
    todayEncounters: 0,
    unconfirmed: [],
    randomThree: [],
    recentEncounters: [],
  );

  factory HomeState.fromJson(Map<String, dynamic> json) {
    return HomeState(
      totalEncounters: json['total_encounters'] as int? ?? 0,
      todayEncounters: json['today_encounters'] as int? ?? 0,
      unconfirmed:
          (json['unconfirmed'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      randomThree:
          (json['random_three'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      recentEncounters:
          (json['recent_encounters'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => RecentEncounter.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
    );
  }
}

/// ホーム画面のデータを管理するプロバイダー
final homeNotifierProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

/// ホーム画面のデータ管理を行うNotifier
class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  FutureOr<HomeState> build() async {
    ref.watch(
      authNotifierProvider.select((s) => s.value?.id),
    ); // ユーザー切替時に状態を作り直す
    return await _fetchHomeData();
  }

  /// ホームデータを取得
  Future<HomeState> _fetchHomeData() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      return HomeState.empty();
    }

    try {
      final repo = ref.read(homeRepositoryProvider);
      final data = await repo.fetchHomeData(user.id);
      return HomeState.fromJson(data);
    } catch (e) {
      // エラー時は空のデータを返す（ダミーデータにフォールバックしない）
      return HomeState.empty();
    }
  }

  /// データを再取得
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchHomeData);
  }

  /// すれ違い保存成功時に、表示カウントを即時に+1する
  /// サーバー再同期前でもUI上で増加が見えるようにする
  void incrementEncounterCountOptimistically() {
    if (!state.hasValue) return;
    final current = state.value!;

    state = AsyncValue.data(
      HomeState(
        totalEncounters: current.totalEncounters + 1,
        todayEncounters: current.todayEncounters + 1,
        unconfirmed: current.unconfirmed,
        randomThree: current.randomThree,
        recentEncounters: current.recentEncounters,
      ),
    );
  }
}
