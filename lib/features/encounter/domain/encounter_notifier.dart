import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/home/data/home_repository.dart';
import 'package:syshack2026/features/encounter/data/encounter_repository.dart';
import 'package:syshack2026/features/encounter/data/pending_encounter_repository.dart';
import 'package:syshack2026/features/encounter/domain/encounter_model.dart';

/// 未確認すれ違いデータの状態を管理するプロバイダー
final encounterNotifierProvider =
    AsyncNotifierProvider<EncounterNotifier, List<EncounterModel>>(
      EncounterNotifier.new,
    );

/// すれ違いデータの取得・確認・BLE検知後の処理を管理するNotifier
class EncounterNotifier extends AsyncNotifier<List<EncounterModel>> {
  @override
  FutureOr<List<EncounterModel>> build() async {
    ref.watch(
      authNotifierProvider.select((s) => s.value?.id),
    ); // ユーザー切替時に状態を作り直す
    // 起動時も含め、未確認データはそのまま全件表示対象にする
    // （アプリ非起動中のすれ違いを次回起動時に確実に表示するため）
    return await _fetchPendingEncounters();
  }

  /// 現在のユーザーIDを取得する
  String? get _currentUserId =>
      ref.read(authNotifierProvider.notifier).currentUserId;

  /// 未確認のすれ違いデータをサーバーとローカルの両方から取得する
  Future<List<EncounterModel>> _fetchPendingEncounters() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      // 未確認データはホーム取得APIから引っ張ってくる（仕様変更への追従）
      final homeRepo = ref.read(homeRepositoryProvider);
      final homeData = await homeRepo.fetchHomeData(userId);
      final unconfirmedList = homeData['unconfirmed'] as List<dynamic>? ?? [];

      // Map → EncounterModel に変換
      final encounters = unconfirmedList.map((item) {
        final data = item as Map<String, dynamic>;
        return EncounterModel(
          id: data['id']?.toString() ?? '',
          encounteredUser: EncounteredUserInfo(
            id: data['id']?.toString() ?? '',
            name: data['name']?.toString() ?? '???',
            iconUrl: data['icon_url']?.toString() ?? '',
            oneWord: data['one_word']?.toString() ?? '',
            // 相手の tech_stack はサーバーが返せば埋める。未対応時は空文字。
            techStack: data['tech_stack']?.toString() ?? '',
          ),
          eventName: data['event_name']?.toString() ?? '',
          encounteredAt:
              DateTime.tryParse(data['created_at']?.toString() ?? '') ??
              DateTime.now(),
          isConfirmed: false,
        );
      }).toList();

      // ローカルにも保存
      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      await localRepo.clearAll();
      for (final encounter in encounters) {
        await localRepo.add(encounter);
      }

      return encounters;
    } catch (e) {
      debugPrint('サーバーから未確認データ取得失敗、ローカルを使用: $e');
      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      return await localRepo.getPending();
    }
  }

  /// BLEですれ違いを検知した時に呼ばれる処理
  Future<void> onEncounterDetected(String targetUserId, {int? eventId}) async {
    final myId = _currentUserId;
    if (myId == null) return;

    try {
      final repo = ref.read(encounterRepositoryProvider);
      final result = await repo.recordEncounter(
        myId: myId,
        targetId: targetUserId,
      );
      if (!result.created) {
        debugPrint(
          'すれ違いは新規保存されませんでした (すでにすれ違っている等): ${result.message ?? 'no message'}',
        );
      }
      state = AsyncValue.data(await _fetchPendingEncounters());
    } catch (e) {
      debugPrint('すれ違い記録の保存に失敗: $e');
    }
  }

  /// サーバーから未確認すれ違いデータを再取得する
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchPendingEncounters);
  }

  /// 「確認した！」ボタンが押された時の処理
  Future<void> confirmAll() async {
    final currentList = state.value ?? [];
    if (currentList.isEmpty) return;

    try {
      final userId = _currentUserId;
      if (userId == null) return;

      // 「確認してホームへ」押下時にサーバー側フラグを更新し、次回起動で同じ相手が再表示されるのを防ぐ。
      final repo = ref.read(encounterRepositoryProvider);
      await repo.confirmAllEncounters(userId);

      final localRepo = ref.read(pendingEncounterRepositoryProvider);
      await localRepo.clearAll();

      state = const AsyncValue.data([]);
    } catch (e) {
      debugPrint('すれ違いデータの確認処理に失敗: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 次回起動時比較用に、現在の未確認ユーザーIDを保存する
  Future<void> saveShutdownSnapshot() async {
    final localRepo = ref.read(pendingEncounterRepositoryProvider);
    final current = state.value ?? await localRepo.getPending();

    await localRepo.saveLastShutdownEncounterUserIds(
      current.map((e) => e.encounteredUser.id).toList(),
    );
  }

  /// 未確認データが存在するか
  bool get hasPending => (state.value ?? []).isNotEmpty;
}
