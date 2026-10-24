import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

/// イベント詳細レスポンスに含まれる参加者情報。
///
/// 参加者は「そのイベントに参加登録済みのユーザー」であり、
/// すれ違い相手の UserModel とは別スコープなので専用モデルとする。
@freezed
abstract class EventParticipant with _$EventParticipant {
  const factory EventParticipant({
    @JsonKey(name: 'user_id') required String userId,
    @Default('') String name,
    @JsonKey(name: 'icon_url') @Default('') String iconUrl,
    @JsonKey(name: 'one_word') @Default('') String oneWord,
    @JsonKey(name: 'registered_at') DateTime? registeredAt,
  }) = _EventParticipant;

  factory EventParticipant.fromJson(Map<String, dynamic> json) =>
      _$EventParticipantFromJson(json);
}

/// イベント詳細モデル。GET /events/:id のレスポンスに対応。
///
/// 既存の PlazaRepository.fetchEvents は `Map<String, dynamic>` のまま扱っており、
/// 段階的にこちらへ移行する想定。今回のスコープは新設のみ。
@freezed
abstract class EventModel with _$EventModel {
  const factory EventModel({
    required int id,
    @Default('') String name,
    @JsonKey(name: 'start_at') DateTime? startAt,
    @JsonKey(name: 'end_at') DateTime? endAt,
    @Default('') String location,
    @JsonKey(name: 'event_url') @Default('') String eventUrl,
    @Default('') String description,
    @Default(0) int accepted,
    @Default(0) int waiting,
    @Default(0) int limit,
    @Default(<EventParticipant>[]) List<EventParticipant> participants,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}
