import 'package:freezed_annotation/freezed_annotation.dart';

part 'encounter_model.freezed.dart';
part 'encounter_model.g.dart';

/// すれ違い通信の1件の記録を表すドメインモデル
/// バックエンドの encounters テーブル + JOINされたユーザー情報に対応
@freezed
abstract class EncounterModel with _$EncounterModel {
  const factory EncounterModel({
    /// すれ違い記録の一意なID
    @Default('') String id,

    /// すれ違ったユーザーの情報（JOINで取得された部分情報）
    required EncounteredUserInfo encounteredUser,

    /// イベントID（イベント中のすれ違いの場合のみ）
    @JsonKey(name: 'event_id') int? eventId,

    /// イベント名（バックエンド: event_name）。
    /// 未設定 or サーバーが返さない場合は空文字。
    @JsonKey(name: 'event_name') @Default('') String eventName,

    /// すれ違った日時
    @JsonKey(name: 'encountered_at') required DateTime encounteredAt,

    /// ユーザーがこのすれ違いを確認済みかどうか
    @JsonKey(name: 'is_confirmed') @Default(false) bool isConfirmed,
  }) = _EncounterModel;

  factory EncounterModel.fromJson(Map<String, dynamic> json) =>
      _$EncounterModelFromJson(json);
}

/// すれ違ったユーザーの部分情報
/// GET /users/:id/encounters のJOINレスポンスに合わせた構造
@freezed
abstract class EncounteredUserInfo with _$EncounteredUserInfo {
  const factory EncounteredUserInfo({
    required String id,
    @Default('???') String name,
    @JsonKey(name: 'icon_url') @Default('') String iconUrl,
    @JsonKey(name: 'one_word') @Default('') String oneWord,

    /// 相手の技術スタック（バックエンド: tech_stack）。
    /// カンマ / スラッシュ / 空白などで区切られた文字列を想定。
    /// サーバーが返さない場合は空文字で、共通タグ表示側では非表示扱いになる。
    @JsonKey(name: 'tech_stack') @Default('') String techStack,
  }) = _EncounteredUserInfo;

  factory EncounteredUserInfo.fromJson(Map<String, dynamic> json) =>
      _$EncounteredUserInfoFromJson(json);
}
