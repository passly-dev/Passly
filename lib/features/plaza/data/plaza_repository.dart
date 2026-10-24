import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/core/network/dio_client.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';

final plazaRepositoryProvider = Provider<PlazaRepository>((ref) {
  return PlazaRepository(ref.read(dioProvider));
});

/// 広場画面のすれ違い情報を取得するリポジトリ
class PlazaRepository {
  final Dio _dio;

  PlazaRepository(this._dio);

  /// ランダムで10人のすれ違い相手を取得する（GET /users/:id/encounters）
  ///
  /// ※仕様書のレスポンス例は単一のユーザーオブジェクトとなっているが、
  /// 役割として「10人取得します」と記載されているため、
  /// 単一オブジェクト通信・配列通信のどちらがバックエンドから返ってきても
  /// 安全にパースしてリスト化できるように実装。
  Future<List<UserModel>> fetchEncounters(String userId) async {
    final response = await _dio.get('/users/$userId/encounters');
    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (data is Map<String, dynamic>) {
      if (data['encounters'] is List) {
        final encounters = data['encounters'] as List;
        return encounters
            .whereType<Map>()
            .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [UserModel.fromJson(data)];
    }
    return [];
  }

  /// イベント一覧を取得する（GET /events）
  ///
  /// 画面の既存UIに合わせ、`name/date/count/location` のMap形式へ変換して返す。
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await _dio.get('/events');
    final data = response.data;
    if (data is! List) return [];

    return data.whereType<Map>().map((raw) {
      final map = Map<String, dynamic>.from(raw);
      final startAt = DateTime.tryParse(map['start_at']?.toString() ?? '');
      final date = startAt == null
          ? ''
          : '${startAt.year.toString().padLeft(4, '0')}/${startAt.month.toString().padLeft(2, '0')}/${startAt.day.toString().padLeft(2, '0')}';

      final countValue = map['count'];
      final acceptedValue = map['accepted'];
      final waitingValue = map['waiting'];
      final limitValue = map['limit'];

      final accepted = acceptedValue is int
          ? acceptedValue
          : int.tryParse(acceptedValue?.toString() ?? '') ?? 0;
      final waiting = waitingValue is int
          ? waitingValue
          : int.tryParse(waitingValue?.toString() ?? '') ?? 0;
      final limit = limitValue is int
          ? limitValue
          : int.tryParse(limitValue?.toString() ?? '') ?? 0;

      final count = countValue is int
          ? countValue
          : int.tryParse(countValue?.toString() ?? '') ?? accepted;

      return {
        'id': map['id'],
        'name': map['name']?.toString() ?? '',
        'date': date,
        'count': count,
        'accepted': accepted,
        'waiting': waiting,
        'limit': limit,
        'location': map['location']?.toString() ?? '',
        'event_url': map['event_url']?.toString() ?? '',
      };
    }).toList();
  }
}
