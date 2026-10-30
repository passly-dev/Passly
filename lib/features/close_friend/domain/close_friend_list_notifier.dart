import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:passly/features/auth/domain/auth_notifier.dart';
import 'package:passly/features/user/domain/user_model.dart';
import 'package:passly/features/close_friend/data/close_friend_repository.dart';

/// ログイン中ユーザーの「親しい友達」一覧を管理する Notifier。
///
/// build() でリポジトリから初期リストを取得し、addFriend / removeFriend
/// は通信を待たずにリストを書き換えてからリポジトリを更新する。プロフィール画面はこのプロバイダーを
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

  /// 追加・解除の通信中のユーザー ID。同じ相手への連打で順番が崩れないようにする。
  final Set<String> _pending = {};

  /// 親しい友達に追加する。
  ///
  /// 通信を待たずに先に [user] をリストへ入れて画面をすぐ切り替え、
  /// 失敗したら元のリストに戻して例外を投げ直す。
  Future<void> addFriend(UserModel user) {
    return _update(
      user.id,
      (list) => [...list.where((u) => u.id != user.id), user],
      (repo, myId) => repo.addCloseFriend(myId: myId, targetId: user.id),
    );
  }

  /// 親しい友達から解除する。追加と同じく先に画面へ反映する。
  Future<void> removeFriend(String targetId) {
    return _update(
      targetId,
      (list) => list.where((u) => u.id != targetId).toList(),
      (repo, myId) => repo.removeCloseFriend(myId: myId, targetId: targetId),
    );
  }

  Future<void> _update(
    String targetId,
    List<UserModel> Function(List<UserModel> list) apply,
    Future<void> Function(CloseFriendRepository repo, String myId) request,
  ) async {
    final myId = ref.read(authNotifierProvider).value?.id;
    if (myId == null || !_pending.add(targetId)) return;

    final previous = state.value ?? const <UserModel>[];
    state = AsyncData(apply(previous));
    try {
      await request(ref.read(closeFriendRepositoryProvider), myId);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    } finally {
      _pending.remove(targetId);
    }
  }
}
