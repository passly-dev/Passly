import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syshack2026/core/network/dio_client.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(dioProvider), ref.read(secureStorageProvider));
});

/// ホーム画面のデータを取得するリポジトリ
class HomeRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  HomeRepository(this._dio, this._storage);

  /// ホーム画面の表示に必要なデータを一括で取得する（GET /users/:id/home）
  /// 仕様レスポンス: {"total_encounters": 15, "today_encounters": 3, "unconfirmed": [...], "random_three": [...]}
  Future<Map<String, dynamic>> fetchHomeData(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/home');
      final data = response.data as Map<String, dynamic>;

      // オフライン用にキャッシュを保存
      await _storage.write(
        key: 'cached_home_data_$userId',
        value: jsonEncode(data),
      );

      return data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        // ネットワークエラー時はキャッシュを返す
        final cachedStr = await _storage.read(key: 'cached_home_data_$userId');
        if (cachedStr != null) {
          try {
            return jsonDecode(cachedStr) as Map<String, dynamic>;
          } catch (_) {
            // キャッシュ破損時はスロー
          }
        }
      }
      rethrow;
    }
  }
}
