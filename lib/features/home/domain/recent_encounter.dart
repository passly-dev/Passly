import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_encounter.freezed.dart';
part 'recent_encounter.g.dart';

/// ホーム画面「最近の出会い」セクションで表示する 1 件分のデータ。
///
/// GET /users/:id/home の recent_encounters 配列の各要素に対応する。
/// UserModel より情報量が絞られているため専用モデルとする。
@freezed
abstract class RecentEncounter with _$RecentEncounter {
  const factory RecentEncounter({
    @JsonKey(name: 'user_id') required String userId,
    @Default('') String name,
    @JsonKey(name: 'icon_url') @Default('') String iconUrl,
    @JsonKey(name: 'met_at') required DateTime metAt,
    @JsonKey(name: 'event_name') @Default('') String eventName,
  }) = _RecentEncounter;

  factory RecentEncounter.fromJson(Map<String, dynamic> json) =>
      _$RecentEncounterFromJson(json);
}
