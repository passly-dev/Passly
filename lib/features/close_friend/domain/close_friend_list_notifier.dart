import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/features/close_friend/data/close_friend_repository.dart';

/// ログイン中ユーザーの「親しい友達」一覧を管理する Notifier。
///
/// build() でリポジトリから初期リストを取得し、addFriend / removeFriend
/// でリポジトリ更新後に再取得する。プロフィール画面はこのプロバイダーを
/// watch し、対象ユーザー ID がリストに含まれるかで表示状態を切り替える。
final closeFriendListProvider =
    AsyncNotifierProvider<CloseFriendListNotifier, List<UserModel>>(
      CloseFriendListNotifier.new,
    );

class CloseFriendListNotifier extends AsyncNotifier<List<UserModel>> {
  @override
  FutureOr<List<UserModel>> build() async {
    ref.watch(
      authNotifierProvider.select((s) => s.value?.id),
    ); // ユーザー切替時に状態を作り直す
    return _fetch();
  }

  Future<List<UserModel>> _fetch() async {
    final myId = ref.read(authNotifierProvider).value?.id;
    if (myId == null) return const [];

    final repo = ref.read(closeFriendRepositoryProvider);
    return repo.fetchCloseFriends(myId);
  }

  /// 指定ユーザーが親しい友達か判定する。
  bool isCloseFriend(String targetId) {
    return state.value?.any((u) => u.id == targetId) ?? false;
  }

  /// 親しい友達に追加してリストを再取得する。
  Future<void> addFriend(String targetId) async {
    final myId = ref.read(authNotifierProvider).value?.id;
    if (myId == null) return;

    final repo = ref.read(closeFriendRepositoryProvider);
    await repo.addCloseFriend(myId: myId, targetId: targetId);
    state = await AsyncValue.guard(_fetch);
  }

  /// 親しい友達から解除してリストを再取得する。
  Future<void> removeFriend(String targetId) async {
    final myId = ref.read(authNotifierProvider).value?.id;
    if (myId == null) return;

    final repo = ref.read(closeFriendRepositoryProvider);
    await repo.removeCloseFriend(myId: myId, targetId: targetId);
    state = await AsyncValue.guard(_fetch);
  }
}
