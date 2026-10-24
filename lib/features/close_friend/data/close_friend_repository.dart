import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:syshack2026/core/config/feature_flags.dart';
import 'package:syshack2026/core/network/dio_client.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/features/close_friend/data/close_friend_repository_api.dart';
import 'package:syshack2026/features/close_friend/data/close_friend_repository_mock.dart';

/// 「親しい友達」機能の抽象インターフェース。
///
/// バックエンド未実装のため、FeatureFlags.useMockCloseFriends で
/// モック実装と実 API 実装を切り替える。
///
/// 親しい友達は「そのユーザーが特別に印を付けた相手」であり、
/// 実体は UserModel。専用モデルは作らず UserModel を再利用する。
abstract class CloseFriendRepository {
  /// POST /users/:id/close-friends — 相手を親しい友達に追加する。
  Future<void> addCloseFriend({required String myId, required String targetId});

  /// DELETE /users/:id/close-friends/:target_id — 親しい友達から解除する。
  Future<void> removeCloseFriend({
    required String myId,
    required String targetId,
  });

  /// GET /users/:id/close-friends — 自分の親しい友達一覧を取得する。
  Future<List<UserModel>> fetchCloseFriends(String myId);
}

final closeFriendRepositoryProvider = Provider<CloseFriendRepository>((ref) {
  if (FeatureFlags.useMockCloseFriends) {
    return CloseFriendRepositoryMock();
  }
  return CloseFriendRepositoryApi(ref.read(dioProvider));
});
