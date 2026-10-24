// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_encounter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LastEncounter _$LastEncounterFromJson(Map<String, dynamic> json) =>
    _LastEncounter(
      metAt: DateTime.parse(json['met_at'] as String),
      eventName: json['event_name'] as String? ?? '',
    );

Map<String, dynamic> _$LastEncounterToJson(_LastEncounter instance) =>
    <String, dynamic>{
      'met_at': instance.metAt.toIso8601String(),
      'event_name': instance.eventName,
    };
