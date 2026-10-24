// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'last_encounter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LastEncounter {

@JsonKey(name: 'met_at') DateTime get metAt;@JsonKey(name: 'event_name') String get eventName;
/// Create a copy of LastEncounter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LastEncounterCopyWith<LastEncounter> get copyWith => _$LastEncounterCopyWithImpl<LastEncounter>(this as LastEncounter, _$identity);

  /// Serializes this LastEncounter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LastEncounter&&(identical(other.metAt, metAt) || other.metAt == metAt)&&(identical(other.eventName, eventName) || other.eventName == eventName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metAt,eventName);

@override
String toString() {
  return 'LastEncounter(metAt: $metAt, eventName: $eventName)';
}


}

/// @nodoc
abstract mixin class $LastEncounterCopyWith<$Res>  {
  factory $LastEncounterCopyWith(LastEncounter value, $Res Function(LastEncounter) _then) = _$LastEncounterCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'met_at') DateTime metAt,@JsonKey(name: 'event_name') String eventName
});




}
/// @nodoc
class _$LastEncounterCopyWithImpl<$Res>
    implements $LastEncounterCopyWith<$Res> {
  _$LastEncounterCopyWithImpl(this._self, this._then);

  final LastEncounter _self;
  final $Res Function(LastEncounter) _then;

/// Create a copy of LastEncounter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metAt = null,Object? eventName = null,}) {
  return _then(_self.copyWith(
metAt: null == metAt ? _self.metAt : metAt // ignore: cast_nullable_to_non_nullable
as DateTime,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LastEncounter].
extension LastEncounterPatterns on LastEncounter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LastEncounter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LastEncounter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LastEncounter value)  $default,){
final _that = this;
switch (_that) {
case _LastEncounter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LastEncounter value)?  $default,){
final _that = this;
switch (_that) {
case _LastEncounter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'met_at')  DateTime metAt, @JsonKey(name: 'event_name')  String eventName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LastEncounter() when $default != null:
return $default(_that.metAt,_that.eventName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'met_at')  DateTime metAt, @JsonKey(name: 'event_name')  String eventName)  $default,) {final _that = this;
switch (_that) {
case _LastEncounter():
return $default(_that.metAt,_that.eventName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'met_at')  DateTime metAt, @JsonKey(name: 'event_name')  String eventName)?  $default,) {final _that = this;
switch (_that) {
case _LastEncounter() when $default != null:
return $default(_that.metAt,_that.eventName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LastEncounter implements LastEncounter {
  const _LastEncounter({@JsonKey(name: 'met_at') required this.metAt, @JsonKey(name: 'event_name') this.eventName = ''});
  factory _LastEncounter.fromJson(Map<String, dynamic> json) => _$LastEncounterFromJson(json);

@override@JsonKey(name: 'met_at') final  DateTime metAt;
@override@JsonKey(name: 'event_name') final  String eventName;

/// Create a copy of LastEncounter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LastEncounterCopyWith<_LastEncounter> get copyWith => __$LastEncounterCopyWithImpl<_LastEncounter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LastEncounterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LastEncounter&&(identical(other.metAt, metAt) || other.metAt == metAt)&&(identical(other.eventName, eventName) || other.eventName == eventName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metAt,eventName);

@override
String toString() {
  return 'LastEncounter(metAt: $metAt, eventName: $eventName)';
}


}

/// @nodoc
abstract mixin class _$LastEncounterCopyWith<$Res> implements $LastEncounterCopyWith<$Res> {
  factory _$LastEncounterCopyWith(_LastEncounter value, $Res Function(_LastEncounter) _then) = __$LastEncounterCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'met_at') DateTime metAt,@JsonKey(name: 'event_name') String eventName
});




}
/// @nodoc
class __$LastEncounterCopyWithImpl<$Res>
    implements _$LastEncounterCopyWith<$Res> {
  __$LastEncounterCopyWithImpl(this._self, this._then);

  final _LastEncounter _self;
  final $Res Function(_LastEncounter) _then;

/// Create a copy of LastEncounter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metAt = null,Object? eventName = null,}) {
  return _then(_LastEncounter(
metAt: null == metAt ? _self.metAt : metAt // ignore: cast_nullable_to_non_nullable
as DateTime,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
