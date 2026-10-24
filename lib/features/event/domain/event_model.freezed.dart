// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventParticipant {

@JsonKey(name: 'user_id') String get userId; String get name;@JsonKey(name: 'icon_url') String get iconUrl;@JsonKey(name: 'one_word') String get oneWord;@JsonKey(name: 'registered_at') DateTime? get registeredAt;
/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventParticipantCopyWith<EventParticipant> get copyWith => _$EventParticipantCopyWithImpl<EventParticipant>(this as EventParticipant, _$identity);

  /// Serializes this EventParticipant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventParticipant&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.oneWord, oneWord) || other.oneWord == oneWord)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,iconUrl,oneWord,registeredAt);

@override
String toString() {
  return 'EventParticipant(userId: $userId, name: $name, iconUrl: $iconUrl, oneWord: $oneWord, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class $EventParticipantCopyWith<$Res>  {
  factory $EventParticipantCopyWith(EventParticipant value, $Res Function(EventParticipant) _then) = _$EventParticipantCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'icon_url') String iconUrl,@JsonKey(name: 'one_word') String oneWord,@JsonKey(name: 'registered_at') DateTime? registeredAt
});




}
/// @nodoc
class _$EventParticipantCopyWithImpl<$Res>
    implements $EventParticipantCopyWith<$Res> {
  _$EventParticipantCopyWithImpl(this._self, this._then);

  final EventParticipant _self;
  final $Res Function(EventParticipant) _then;

/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? iconUrl = null,Object? oneWord = null,Object? registeredAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,oneWord: null == oneWord ? _self.oneWord : oneWord // ignore: cast_nullable_to_non_nullable
as String,registeredAt: freezed == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventParticipant].
extension EventParticipantPatterns on EventParticipant {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventParticipant() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventParticipant value)  $default,){
final _that = this;
switch (_that) {
case _EventParticipant():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _EventParticipant() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'one_word')  String oneWord, @JsonKey(name: 'registered_at')  DateTime? registeredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventParticipant() when $default != null:
return $default(_that.userId,_that.name,_that.iconUrl,_that.oneWord,_that.registeredAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'one_word')  String oneWord, @JsonKey(name: 'registered_at')  DateTime? registeredAt)  $default,) {final _that = this;
switch (_that) {
case _EventParticipant():
return $default(_that.userId,_that.name,_that.iconUrl,_that.oneWord,_that.registeredAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'one_word')  String oneWord, @JsonKey(name: 'registered_at')  DateTime? registeredAt)?  $default,) {final _that = this;
switch (_that) {
case _EventParticipant() when $default != null:
return $default(_that.userId,_that.name,_that.iconUrl,_that.oneWord,_that.registeredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventParticipant implements EventParticipant {
  const _EventParticipant({@JsonKey(name: 'user_id') required this.userId, this.name = '', @JsonKey(name: 'icon_url') this.iconUrl = '', @JsonKey(name: 'one_word') this.oneWord = '', @JsonKey(name: 'registered_at') this.registeredAt});
  factory _EventParticipant.fromJson(Map<String, dynamic> json) => _$EventParticipantFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'icon_url') final  String iconUrl;
@override@JsonKey(name: 'one_word') final  String oneWord;
@override@JsonKey(name: 'registered_at') final  DateTime? registeredAt;

/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventParticipantCopyWith<_EventParticipant> get copyWith => __$EventParticipantCopyWithImpl<_EventParticipant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventParticipant&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.oneWord, oneWord) || other.oneWord == oneWord)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,iconUrl,oneWord,registeredAt);

@override
String toString() {
  return 'EventParticipant(userId: $userId, name: $name, iconUrl: $iconUrl, oneWord: $oneWord, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class _$EventParticipantCopyWith<$Res> implements $EventParticipantCopyWith<$Res> {
  factory _$EventParticipantCopyWith(_EventParticipant value, $Res Function(_EventParticipant) _then) = __$EventParticipantCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'icon_url') String iconUrl,@JsonKey(name: 'one_word') String oneWord,@JsonKey(name: 'registered_at') DateTime? registeredAt
});




}
/// @nodoc
class __$EventParticipantCopyWithImpl<$Res>
    implements _$EventParticipantCopyWith<$Res> {
  __$EventParticipantCopyWithImpl(this._self, this._then);

  final _EventParticipant _self;
  final $Res Function(_EventParticipant) _then;

/// Create a copy of EventParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? iconUrl = null,Object? oneWord = null,Object? registeredAt = freezed,}) {
  return _then(_EventParticipant(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,oneWord: null == oneWord ? _self.oneWord : oneWord // ignore: cast_nullable_to_non_nullable
as String,registeredAt: freezed == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EventModel {

 int get id; String get name;@JsonKey(name: 'start_at') DateTime? get startAt;@JsonKey(name: 'end_at') DateTime? get endAt; String get location;@JsonKey(name: 'event_url') String get eventUrl; String get description; int get accepted; int get waiting; int get limit; List<EventParticipant> get participants;
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelCopyWith<EventModel> get copyWith => _$EventModelCopyWithImpl<EventModel>(this as EventModel, _$identity);

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.eventUrl, eventUrl) || other.eventUrl == eventUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.accepted, accepted) || other.accepted == accepted)&&(identical(other.waiting, waiting) || other.waiting == waiting)&&(identical(other.limit, limit) || other.limit == limit)&&const DeepCollectionEquality().equals(other.participants, participants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,startAt,endAt,location,eventUrl,description,accepted,waiting,limit,const DeepCollectionEquality().hash(participants));

@override
String toString() {
  return 'EventModel(id: $id, name: $name, startAt: $startAt, endAt: $endAt, location: $location, eventUrl: $eventUrl, description: $description, accepted: $accepted, waiting: $waiting, limit: $limit, participants: $participants)';
}


}

/// @nodoc
abstract mixin class $EventModelCopyWith<$Res>  {
  factory $EventModelCopyWith(EventModel value, $Res Function(EventModel) _then) = _$EventModelCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'start_at') DateTime? startAt,@JsonKey(name: 'end_at') DateTime? endAt, String location,@JsonKey(name: 'event_url') String eventUrl, String description, int accepted, int waiting, int limit, List<EventParticipant> participants
});




}
/// @nodoc
class _$EventModelCopyWithImpl<$Res>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._self, this._then);

  final EventModel _self;
  final $Res Function(EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? startAt = freezed,Object? endAt = freezed,Object? location = null,Object? eventUrl = null,Object? description = null,Object? accepted = null,Object? waiting = null,Object? limit = null,Object? participants = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,eventUrl: null == eventUrl ? _self.eventUrl : eventUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as int,waiting: null == waiting ? _self.waiting : waiting // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<EventParticipant>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventModel].
extension EventModelPatterns on EventModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventModel value)  $default,){
final _that = this;
switch (_that) {
case _EventModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'start_at')  DateTime? startAt, @JsonKey(name: 'end_at')  DateTime? endAt,  String location, @JsonKey(name: 'event_url')  String eventUrl,  String description,  int accepted,  int waiting,  int limit,  List<EventParticipant> participants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.name,_that.startAt,_that.endAt,_that.location,_that.eventUrl,_that.description,_that.accepted,_that.waiting,_that.limit,_that.participants);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'start_at')  DateTime? startAt, @JsonKey(name: 'end_at')  DateTime? endAt,  String location, @JsonKey(name: 'event_url')  String eventUrl,  String description,  int accepted,  int waiting,  int limit,  List<EventParticipant> participants)  $default,) {final _that = this;
switch (_that) {
case _EventModel():
return $default(_that.id,_that.name,_that.startAt,_that.endAt,_that.location,_that.eventUrl,_that.description,_that.accepted,_that.waiting,_that.limit,_that.participants);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'start_at')  DateTime? startAt, @JsonKey(name: 'end_at')  DateTime? endAt,  String location, @JsonKey(name: 'event_url')  String eventUrl,  String description,  int accepted,  int waiting,  int limit,  List<EventParticipant> participants)?  $default,) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.name,_that.startAt,_that.endAt,_that.location,_that.eventUrl,_that.description,_that.accepted,_that.waiting,_that.limit,_that.participants);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventModel implements EventModel {
  const _EventModel({required this.id, this.name = '', @JsonKey(name: 'start_at') this.startAt, @JsonKey(name: 'end_at') this.endAt, this.location = '', @JsonKey(name: 'event_url') this.eventUrl = '', this.description = '', this.accepted = 0, this.waiting = 0, this.limit = 0, final  List<EventParticipant> participants = const <EventParticipant>[]}): _participants = participants;
  factory _EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);

@override final  int id;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'start_at') final  DateTime? startAt;
@override@JsonKey(name: 'end_at') final  DateTime? endAt;
@override@JsonKey() final  String location;
@override@JsonKey(name: 'event_url') final  String eventUrl;
@override@JsonKey() final  String description;
@override@JsonKey() final  int accepted;
@override@JsonKey() final  int waiting;
@override@JsonKey() final  int limit;
 final  List<EventParticipant> _participants;
@override@JsonKey() List<EventParticipant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}


/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventModelCopyWith<_EventModel> get copyWith => __$EventModelCopyWithImpl<_EventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.eventUrl, eventUrl) || other.eventUrl == eventUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.accepted, accepted) || other.accepted == accepted)&&(identical(other.waiting, waiting) || other.waiting == waiting)&&(identical(other.limit, limit) || other.limit == limit)&&const DeepCollectionEquality().equals(other._participants, _participants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,startAt,endAt,location,eventUrl,description,accepted,waiting,limit,const DeepCollectionEquality().hash(_participants));

@override
String toString() {
  return 'EventModel(id: $id, name: $name, startAt: $startAt, endAt: $endAt, location: $location, eventUrl: $eventUrl, description: $description, accepted: $accepted, waiting: $waiting, limit: $limit, participants: $participants)';
}


}

/// @nodoc
abstract mixin class _$EventModelCopyWith<$Res> implements $EventModelCopyWith<$Res> {
  factory _$EventModelCopyWith(_EventModel value, $Res Function(_EventModel) _then) = __$EventModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'start_at') DateTime? startAt,@JsonKey(name: 'end_at') DateTime? endAt, String location,@JsonKey(name: 'event_url') String eventUrl, String description, int accepted, int waiting, int limit, List<EventParticipant> participants
});




}
/// @nodoc
class __$EventModelCopyWithImpl<$Res>
    implements _$EventModelCopyWith<$Res> {
  __$EventModelCopyWithImpl(this._self, this._then);

  final _EventModel _self;
  final $Res Function(_EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? startAt = freezed,Object? endAt = freezed,Object? location = null,Object? eventUrl = null,Object? description = null,Object? accepted = null,Object? waiting = null,Object? limit = null,Object? participants = null,}) {
  return _then(_EventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,eventUrl: null == eventUrl ? _self.eventUrl : eventUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as int,waiting: null == waiting ? _self.waiting : waiting // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<EventParticipant>,
  ));
}


}

// dart format on
