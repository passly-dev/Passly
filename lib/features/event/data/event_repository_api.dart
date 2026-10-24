import 'package:dio/dio.dart';

import 'package:syshack2026/features/event/domain/event_model.dart';
import 'package:syshack2026/features/event/data/event_repository.dart';

/// 実バックエンド向けの EventRepository 実装。
///
/// サーバー側 GET /events/:id の実装完了後に疎通確認する想定。
/// レスポンス形式は「単一のイベントオブジェクトを直接返す」パターンと
/// 「{event: {...}} でラップして返す」パターンの両方を許容する。
class EventRepositoryApi implements EventRepository {
  final Dio _dio;

  EventRepositoryApi(this._dio);

  @override
  Future<EventModel> fetchEventDetail(int eventId) async {
    try {
      final response = await _dio.get('/events/$eventId');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        // {"event": {...}} でラップされている場合を先に確認
        final wrapped = data['event'];
        if (wrapped is Map) {
          return EventModel.fromJson(Map<String, dynamic>.from(wrapped));
        }
        return EventModel.fromJson(data);
      }

      throw Exception('イベント詳細のレスポンス形式が不正です');
    } on DioException catch (e) {
      throwEventApiError(e, 'イベント詳細の取得に失敗');
    }
  }
}
