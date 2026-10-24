// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_encounter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecentEncounter {

@JsonKey(name: 'user_id') String get userId; String get name;@JsonKey(name: 'icon_url') String get iconUrl;@JsonKey(name: 'met_at') DateTime get metAt;@JsonKey(name: 'event_name') String get eventName;
/// Create a copy of RecentEncounter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentEncounterCopyWith<RecentEncounter> get copyWith => _$RecentEncounterCopyWithImpl<RecentEncounter>(this as RecentEncounter, _$identity);

  /// Serializes this RecentEncounter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentEncounter&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.metAt, metAt) || other.metAt == metAt)&&(identical(other.eventName, eventName) || other.eventName == eventName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,iconUrl,metAt,eventName);

@override
String toString() {
  return 'RecentEncounter(userId: $userId, name: $name, iconUrl: $iconUrl, metAt: $metAt, eventName: $eventName)';
}


}

/// @nodoc
abstract mixin class $RecentEncounterCopyWith<$Res>  {
  factory $RecentEncounterCopyWith(RecentEncounter value, $Res Function(RecentEncounter) _then) = _$RecentEncounterCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'icon_url') String iconUrl,@JsonKey(name: 'met_at') DateTime metAt,@JsonKey(name: 'event_name') String eventName
});




}
/// @nodoc
class _$RecentEncounterCopyWithImpl<$Res>
    implements $RecentEncounterCopyWith<$Res> {
  _$RecentEncounterCopyWithImpl(this._self, this._then);

  final RecentEncounter _self;
  final $Res Function(RecentEncounter) _then;

/// Create a copy of RecentEncounter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? iconUrl = null,Object? metAt = null,Object? eventName = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,metAt: null == metAt ? _self.metAt : metAt // ignore: cast_nullable_to_non_nullable
as DateTime,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentEncounter].
extension RecentEncounterPatterns on RecentEncounter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentEncounter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentEncounter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentEncounter value)  $default,){
final _that = this;
switch (_that) {
case _RecentEncounter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentEncounter value)?  $default,){
final _that = this;
switch (_that) {
case _RecentEncounter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'met_at')  DateTime metAt, @JsonKey(name: 'event_name')  String eventName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentEncounter() when $default != null:
return $default(_that.userId,_that.name,_that.iconUrl,_that.metAt,_that.eventName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'met_at')  DateTime metAt, @JsonKey(name: 'event_name')  String eventName)  $default,) {final _that = this;
switch (_that) {
case _RecentEncounter():
return $default(_that.userId,_that.name,_that.iconUrl,_that.metAt,_that.eventName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'met_at')  DateTime metAt, @JsonKey(name: 'event_name')  String eventName)?  $default,) {final _that = this;
switch (_that) {
case _RecentEncounter() when $default != null:
return $default(_that.userId,_that.name,_that.iconUrl,_that.metAt,_that.eventName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentEncounter implements RecentEncounter {
  const _RecentEncounter({@JsonKey(name: 'user_id') required this.userId, this.name = '', @JsonKey(name: 'icon_url') this.iconUrl = '', @JsonKey(name: 'met_at') required this.metAt, @JsonKey(name: 'event_name') this.eventName = ''});
  factory _RecentEncounter.fromJson(Map<String, dynamic> json) => _$RecentEncounterFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'icon_url') final  String iconUrl;
@override@JsonKey(name: 'met_at') final  DateTime metAt;
@override@JsonKey(name: 'event_name') final  String eventName;

/// Create a copy of RecentEncounter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentEncounterCopyWith<_RecentEncounter> get copyWith => __$RecentEncounterCopyWithImpl<_RecentEncounter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentEncounterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentEncounter&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.metAt, metAt) || other.metAt == metAt)&&(identical(other.eventName, eventName) || other.eventName == eventName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,iconUrl,metAt,eventName);

@override
String toString() {
  return 'RecentEncounter(userId: $userId, name: $name, iconUrl: $iconUrl, metAt: $metAt, eventName: $eventName)';
}


}

/// @nodoc
abstract mixin class _$RecentEncounterCopyWith<$Res> implements $RecentEncounterCopyWith<$Res> {
  factory _$RecentEncounterCopyWith(_RecentEncounter value, $Res Function(_RecentEncounter) _then) = __$RecentEncounterCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'icon_url') String iconUrl,@JsonKey(name: 'met_at') DateTime metAt,@JsonKey(name: 'event_name') String eventName
});




}
/// @nodoc
class __$RecentEncounterCopyWithImpl<$Res>
    implements _$RecentEncounterCopyWith<$Res> {
  __$RecentEncounterCopyWithImpl(this._self, this._then);

  final _RecentEncounter _self;
  final $Res Function(_RecentEncounter) _then;

/// Create a copy of RecentEncounter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? iconUrl = null,Object? metAt = null,Object? eventName = null,}) {
  return _then(_RecentEncounter(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,metAt: null == metAt ? _self.metAt : metAt // ignore: cast_nullable_to_non_nullable
as DateTime,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
