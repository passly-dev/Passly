import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/mypage/data/achievement_repository.dart';

final achievementNotifierProvider =
    AsyncNotifierProvider<AchievementNotifier, AchievementResponse>(
      AchievementNotifier.new,
    );

class AchievementNotifier extends AsyncNotifier<AchievementResponse> {
  @override
  FutureOr<AchievementResponse> build() async {
    ref.watch(
      authNotifierProvider.select((s) => s.value?.id),
    ); // ユーザー切替時に状態を作り直す
    return _fetch();
  }

  Future<AchievementResponse> _fetch() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      return const AchievementResponse(
        unlockedCount: 0,
        totalCount: 0,
        achievements: [],
      );
    }

    final repo = ref.read(achievementRepositoryProvider);
    return repo.fetchAchievements(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}
