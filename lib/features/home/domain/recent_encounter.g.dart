// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_encounter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecentEncounter _$RecentEncounterFromJson(Map<String, dynamic> json) =>
    _RecentEncounter(
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      metAt: DateTime.parse(json['met_at'] as String),
      eventName: json['event_name'] as String? ?? '',
    );

Map<String, dynamic> _$RecentEncounterToJson(_RecentEncounter instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'icon_url': instance.iconUrl,
      'met_at': instance.metAt.toIso8601String(),
      'event_name': instance.eventName,
    };
