import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:passly/core/config/feature_flags.dart';
import 'package:passly/core/network/dio_client.dart';
import 'package:passly/features/event/domain/event_model.dart';
import 'package:passly/features/event/data/event_repository_api.dart';
import 'package:passly/features/event/data/event_repository_mock.dart';

/// イベント詳細取得の抽象インターフェース。
///
/// バックエンド未実装のため、FeatureFlags.useMockEventDetail で
/// モック実装と実 API 実装を切り替える。
abstract class EventRepository {
  /// GET /events/:id — イベント詳細と参加者一覧を取得。
  Future<EventModel> fetchEventDetail(int eventId);
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  if (FeatureFlags.useMockEventDetail && !FeatureFlags.demoMode) {
    return EventRepositoryMock();
  }
  return EventRepositoryApi(ref.read(dioProvider));
});

/// DioException を既存 Repository と同じ形式でラップするヘルパー。
Never throwEventApiError(DioException e, String prefix) {
  throw Exception('$prefix: ${e.message}');
}
