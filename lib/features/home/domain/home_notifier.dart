import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passly/features/home/data/home_repository.dart';
import 'package:passly/features/auth/domain/auth_notifier.dart';
import 'package:passly/features/encounter/domain/encounter_notifier.dart';
import 'package:passly/features/home/domain/recent_encounter.dart';

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

    // アプリを開いたまますれ違ったら，下に引っぱらなくても一覧を取り直す。
    // 未確認のすれ違いの顔ぶれが変わったとき（新しくすれ違った・確認した）に動く。
    ref.listen<String?>(pendingEncounterKeyProvider, (previous, next) {
      if (previous == null || next == null || previous == next) return;
      refresh();
    });

    // 前回のデータがあれば先に出し，最新はうしろで取り直す。
    final cached = await _readCache();
    if (cached != null) {
      Future.microtask(refresh);
      return cached;
    }
    return await _fetchHomeData();
  }

  Future<HomeState?> _readCache() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return null;
    try {
      final data = await ref
          .read(homeRepositoryProvider)
          .readCachedHomeData(user.id);
      return data == null ? null : HomeState.fromJson(data);
    } catch (_) {
      return null;
    }
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
  ///
  /// すでに表示しているときは読み込み中にしない（読み込み表示に切り替わって点滅しないように）。
  Future<void> refresh() async {
    final previous = state.value;
    if (previous == null) state = const AsyncValue.loading();
    final next = await AsyncValue.guard(_fetchHomeData);
    state = next.hasError && previous != null
        ? AsyncValue.data(previous)
        : next;
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
