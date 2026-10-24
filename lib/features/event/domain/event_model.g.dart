// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventParticipant _$EventParticipantFromJson(Map<String, dynamic> json) =>
    _EventParticipant(
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      oneWord: json['one_word'] as String? ?? '',
      registeredAt: json['registered_at'] == null
          ? null
          : DateTime.parse(json['registered_at'] as String),
    );

Map<String, dynamic> _$EventParticipantToJson(_EventParticipant instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'icon_url': instance.iconUrl,
      'one_word': instance.oneWord,
      'registered_at': instance.registeredAt?.toIso8601String(),
    };

_EventModel _$EventModelFromJson(Map<String, dynamic> json) => _EventModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? '',
  startAt: json['start_at'] == null
      ? null
      : DateTime.parse(json['start_at'] as String),
  endAt: json['end_at'] == null
      ? null
      : DateTime.parse(json['end_at'] as String),
  location: json['location'] as String? ?? '',
  eventUrl: json['event_url'] as String? ?? '',
  description: json['description'] as String? ?? '',
  accepted: (json['accepted'] as num?)?.toInt() ?? 0,
  waiting: (json['waiting'] as num?)?.toInt() ?? 0,
  limit: (json['limit'] as num?)?.toInt() ?? 0,
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map((e) => EventParticipant.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <EventParticipant>[],
);

Map<String, dynamic> _$EventModelToJson(_EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'start_at': instance.startAt?.toIso8601String(),
      'end_at': instance.endAt?.toIso8601String(),
      'location': instance.location,
      'event_url': instance.eventUrl,
      'description': instance.description,
      'accepted': instance.accepted,
      'waiting': instance.waiting,
      'limit': instance.limit,
      'participants': instance.participants,
    };
