import 'package:freezed_annotation/freezed_annotation.dart';

part 'last_encounter.freezed.dart';
part 'last_encounter.g.dart';

/// 「この人と最後にすれ違った時の情報」
///
/// UserModel.lastEncounter として埋め込まれ、プロフィール画面などで
/// 「〇月〇日 SysHack2026 で出会いました」の表示に使う。
@freezed
abstract class LastEncounter with _$LastEncounter {
  const factory LastEncounter({
    @JsonKey(name: 'met_at') required DateTime metAt,
    @JsonKey(name: 'event_name') @Default('') String eventName,
  }) = _LastEncounter;

  factory LastEncounter.fromJson(Map<String, dynamic> json) =>
      _$LastEncounterFromJson(json);
}
