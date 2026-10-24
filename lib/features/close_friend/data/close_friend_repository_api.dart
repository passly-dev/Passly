import 'package:dio/dio.dart';

import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/features/close_friend/data/close_friend_repository.dart';

/// 実バックエンド向けの CloseFriendRepository 実装。
///
/// 一覧レスポンスは「単一配列」と「{close_friends: [...]}」ラップの両方に対応する。
/// 既存 PlazaRepository.fetchEncounters が採用している堅牢化パターンを踏襲。
class CloseFriendRepositoryApi implements CloseFriendRepository {
  final Dio _dio;

  CloseFriendRepositoryApi(this._dio);

  @override
  Future<void> addCloseFriend({
    required String myId,
    required String targetId,
  }) async {
    try {
      await _dio.post(
        '/users/$myId/close-friends',
        data: {'target_id': targetId},
        options: Options(contentType: 'application/json'),
      );
    } on DioException catch (e) {
      throw Exception('親しい友達の追加に失敗: ${e.message}');
    }
  }

  @override
  Future<void> removeCloseFriend({
    required String myId,
    required String targetId,
  }) async {
    try {
      await _dio.delete('/users/$myId/close-friends/$targetId');
    } on DioException catch (e) {
      throw Exception('親しい友達の解除に失敗: ${e.message}');
    }
  }

  @override
  Future<List<UserModel>> fetchCloseFriends(String myId) async {
    try {
      final response = await _dio.get('/users/$myId/close-friends');
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final list = data['close_friends'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      return const <UserModel>[];
    } on DioException catch (e) {
      throw Exception('親しい友達一覧の取得に失敗: ${e.message}');
    }
  }
}
