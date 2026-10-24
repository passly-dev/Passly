import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/features/plaza/data/plaza_repository.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';

/// 広場画面のデータを管理するプロバイダー
final plazaNotifierProvider =
    AsyncNotifierProvider<PlazaNotifier, List<UserModel>>(PlazaNotifier.new);

final plazaEventNotifierProvider =
    AsyncNotifierProvider<PlazaEventNotifier, List<Map<String, dynamic>>>(
      PlazaEventNotifier.new,
    );

/// 広場画面のデータ管理を行うNotifier
class PlazaNotifier extends AsyncNotifier<List<UserModel>> {
  @override
  FutureOr<List<UserModel>> build() async {
    ref.watch(
      authNotifierProvider.select((s) => s.value?.id),
    ); // ユーザー切替時に状態を作り直す
    return await _fetchEncounters();
  }

  /// すれ違い相手を取得
  Future<List<UserModel>> _fetchEncounters() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      return [];
    }

    try {
      final repo = ref.read(plazaRepositoryProvider);
      return await repo.fetchEncounters(user.id);
    } catch (e) {
      return [];
    }
  }

  /// データを再取得
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchEncounters);
  }

  /// ランダムに最大7人を取得
  List<UserModel> getRandomFive() {
    final users = state.value ?? [];
    if (users.isEmpty) return [];

    final shuffled = List<UserModel>.from(users)..shuffle();
    return shuffled.take(7).toList();
  }
}

class PlazaEventNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    ref.watch(
      authNotifierProvider.select((s) => s.value?.id),
    ); // ユーザー切替時に状態を作り直す
    return await _fetchEvents();
  }

  Future<List<Map<String, dynamic>>> _fetchEvents() async {
    try {
      final repo = ref.read(plazaRepositoryProvider);
      return await repo.fetchEvents();
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchEvents);
  }
}
