import 'package:syshack2026/features/user/domain/last_encounter.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/features/user/domain/user_role.dart';
import 'package:syshack2026/features/close_friend/data/close_friend_repository.dart';

/// バックエンド未実装時に UI 開発を進めるためのモック実装。
///
/// 追加 / 解除はメモリ内 Set で保持し、同一プロセス中は状態を保つ。
/// アプリ再起動でリセットされる点は許容（実 API に切り替わるまでの繋ぎ）。
class CloseFriendRepositoryMock implements CloseFriendRepository {
  final Set<String> _closeFriendIds = {'mock_friend_1', 'mock_friend_2'};

  @override
  Future<void> addCloseFriend({
    required String myId,
    required String targetId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _closeFriendIds.add(targetId);
  }

  @override
  Future<void> removeCloseFriend({
    required String myId,
    required String targetId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _closeFriendIds.remove(targetId);
  }

  @override
  Future<List<UserModel>> fetchCloseFriends(String myId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _closeFriendIds.map((id) => _sampleFriend(id)).toList();
  }

  UserModel _sampleFriend(String id) {
    return UserModel(
      id: id,
      name: 'CloseFriend $id',
      oneWord: 'よろしくお願いします',
      role: UserRole.other,
      techStack: 'Flutter / Dart',
      about: 'モックの親しい友達データです。',
      isCloseFriend: true,
      lastEncounter: LastEncounter(
        metAt: DateTime.now().subtract(const Duration(days: 2)),
        eventName: 'SysHack2026',
      ),
    );
  }
}
