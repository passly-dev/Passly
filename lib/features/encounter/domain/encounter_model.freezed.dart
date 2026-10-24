// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encounter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EncounterModel {

/// すれ違い記録の一意なID
 String get id;/// すれ違ったユーザーの情報（JOINで取得された部分情報）
 EncounteredUserInfo get encounteredUser;/// イベントID（イベント中のすれ違いの場合のみ）
@JsonKey(name: 'event_id') int? get eventId;/// イベント名（バックエンド: event_name）。
/// 未設定 or サーバーが返さない場合は空文字。
@JsonKey(name: 'event_name') String get eventName;/// すれ違った日時
@JsonKey(name: 'encountered_at') DateTime get encounteredAt;/// ユーザーがこのすれ違いを確認済みかどうか
@JsonKey(name: 'is_confirmed') bool get isConfirmed;
/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncounterModelCopyWith<EncounterModel> get copyWith => _$EncounterModelCopyWithImpl<EncounterModel>(this as EncounterModel, _$identity);

  /// Serializes this EncounterModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncounterModel&&(identical(other.id, id) || other.id == id)&&(identical(other.encounteredUser, encounteredUser) || other.encounteredUser == encounteredUser)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.encounteredAt, encounteredAt) || other.encounteredAt == encounteredAt)&&(identical(other.isConfirmed, isConfirmed) || other.isConfirmed == isConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,encounteredUser,eventId,eventName,encounteredAt,isConfirmed);

@override
String toString() {
  return 'EncounterModel(id: $id, encounteredUser: $encounteredUser, eventId: $eventId, eventName: $eventName, encounteredAt: $encounteredAt, isConfirmed: $isConfirmed)';
}


}

/// @nodoc
abstract mixin class $EncounterModelCopyWith<$Res>  {
  factory $EncounterModelCopyWith(EncounterModel value, $Res Function(EncounterModel) _then) = _$EncounterModelCopyWithImpl;
@useResult
$Res call({
 String id, EncounteredUserInfo encounteredUser,@JsonKey(name: 'event_id') int? eventId,@JsonKey(name: 'event_name') String eventName,@JsonKey(name: 'encountered_at') DateTime encounteredAt,@JsonKey(name: 'is_confirmed') bool isConfirmed
});


$EncounteredUserInfoCopyWith<$Res> get encounteredUser;

}
/// @nodoc
class _$EncounterModelCopyWithImpl<$Res>
    implements $EncounterModelCopyWith<$Res> {
  _$EncounterModelCopyWithImpl(this._self, this._then);

  final EncounterModel _self;
  final $Res Function(EncounterModel) _then;

/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? encounteredUser = null,Object? eventId = freezed,Object? eventName = null,Object? encounteredAt = null,Object? isConfirmed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encounteredUser: null == encounteredUser ? _self.encounteredUser : encounteredUser // ignore: cast_nullable_to_non_nullable
as EncounteredUserInfo,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,encounteredAt: null == encounteredAt ? _self.encounteredAt : encounteredAt // ignore: cast_nullable_to_non_nullable
as DateTime,isConfirmed: null == isConfirmed ? _self.isConfirmed : isConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncounteredUserInfoCopyWith<$Res> get encounteredUser {
  
  return $EncounteredUserInfoCopyWith<$Res>(_self.encounteredUser, (value) {
    return _then(_self.copyWith(encounteredUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [EncounterModel].
extension EncounterModelPatterns on EncounterModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncounterModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncounterModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncounterModel value)  $default,){
final _that = this;
switch (_that) {
case _EncounterModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncounterModel value)?  $default,){
final _that = this;
switch (_that) {
case _EncounterModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  EncounteredUserInfo encounteredUser, @JsonKey(name: 'event_id')  int? eventId, @JsonKey(name: 'event_name')  String eventName, @JsonKey(name: 'encountered_at')  DateTime encounteredAt, @JsonKey(name: 'is_confirmed')  bool isConfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncounterModel() when $default != null:
return $default(_that.id,_that.encounteredUser,_that.eventId,_that.eventName,_that.encounteredAt,_that.isConfirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  EncounteredUserInfo encounteredUser, @JsonKey(name: 'event_id')  int? eventId, @JsonKey(name: 'event_name')  String eventName, @JsonKey(name: 'encountered_at')  DateTime encounteredAt, @JsonKey(name: 'is_confirmed')  bool isConfirmed)  $default,) {final _that = this;
switch (_that) {
case _EncounterModel():
return $default(_that.id,_that.encounteredUser,_that.eventId,_that.eventName,_that.encounteredAt,_that.isConfirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  EncounteredUserInfo encounteredUser, @JsonKey(name: 'event_id')  int? eventId, @JsonKey(name: 'event_name')  String eventName, @JsonKey(name: 'encountered_at')  DateTime encounteredAt, @JsonKey(name: 'is_confirmed')  bool isConfirmed)?  $default,) {final _that = this;
switch (_that) {
case _EncounterModel() when $default != null:
return $default(_that.id,_that.encounteredUser,_that.eventId,_that.eventName,_that.encounteredAt,_that.isConfirmed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EncounterModel implements EncounterModel {
  const _EncounterModel({this.id = '', required this.encounteredUser, @JsonKey(name: 'event_id') this.eventId, @JsonKey(name: 'event_name') this.eventName = '', @JsonKey(name: 'encountered_at') required this.encounteredAt, @JsonKey(name: 'is_confirmed') this.isConfirmed = false});
  factory _EncounterModel.fromJson(Map<String, dynamic> json) => _$EncounterModelFromJson(json);

/// すれ違い記録の一意なID
@override@JsonKey() final  String id;
/// すれ違ったユーザーの情報（JOINで取得された部分情報）
@override final  EncounteredUserInfo encounteredUser;
/// イベントID（イベント中のすれ違いの場合のみ）
@override@JsonKey(name: 'event_id') final  int? eventId;
/// イベント名（バックエンド: event_name）。
/// 未設定 or サーバーが返さない場合は空文字。
@override@JsonKey(name: 'event_name') final  String eventName;
/// すれ違った日時
@override@JsonKey(name: 'encountered_at') final  DateTime encounteredAt;
/// ユーザーがこのすれ違いを確認済みかどうか
@override@JsonKey(name: 'is_confirmed') final  bool isConfirmed;

/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncounterModelCopyWith<_EncounterModel> get copyWith => __$EncounterModelCopyWithImpl<_EncounterModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EncounterModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncounterModel&&(identical(other.id, id) || other.id == id)&&(identical(other.encounteredUser, encounteredUser) || other.encounteredUser == encounteredUser)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.encounteredAt, encounteredAt) || other.encounteredAt == encounteredAt)&&(identical(other.isConfirmed, isConfirmed) || other.isConfirmed == isConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,encounteredUser,eventId,eventName,encounteredAt,isConfirmed);

@override
String toString() {
  return 'EncounterModel(id: $id, encounteredUser: $encounteredUser, eventId: $eventId, eventName: $eventName, encounteredAt: $encounteredAt, isConfirmed: $isConfirmed)';
}


}

/// @nodoc
abstract mixin class _$EncounterModelCopyWith<$Res> implements $EncounterModelCopyWith<$Res> {
  factory _$EncounterModelCopyWith(_EncounterModel value, $Res Function(_EncounterModel) _then) = __$EncounterModelCopyWithImpl;
@override @useResult
$Res call({
 String id, EncounteredUserInfo encounteredUser,@JsonKey(name: 'event_id') int? eventId,@JsonKey(name: 'event_name') String eventName,@JsonKey(name: 'encountered_at') DateTime encounteredAt,@JsonKey(name: 'is_confirmed') bool isConfirmed
});


@override $EncounteredUserInfoCopyWith<$Res> get encounteredUser;

}
/// @nodoc
class __$EncounterModelCopyWithImpl<$Res>
    implements _$EncounterModelCopyWith<$Res> {
  __$EncounterModelCopyWithImpl(this._self, this._then);

  final _EncounterModel _self;
  final $Res Function(_EncounterModel) _then;

/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? encounteredUser = null,Object? eventId = freezed,Object? eventName = null,Object? encounteredAt = null,Object? isConfirmed = null,}) {
  return _then(_EncounterModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encounteredUser: null == encounteredUser ? _self.encounteredUser : encounteredUser // ignore: cast_nullable_to_non_nullable
as EncounteredUserInfo,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int?,eventName: null == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String,encounteredAt: null == encounteredAt ? _self.encounteredAt : encounteredAt // ignore: cast_nullable_to_non_nullable
as DateTime,isConfirmed: null == isConfirmed ? _self.isConfirmed : isConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncounteredUserInfoCopyWith<$Res> get encounteredUser {
  
  return $EncounteredUserInfoCopyWith<$Res>(_self.encounteredUser, (value) {
    return _then(_self.copyWith(encounteredUser: value));
  });
}
}


/// @nodoc
mixin _$EncounteredUserInfo {

 String get id; String get name;@JsonKey(name: 'icon_url') String get iconUrl;@JsonKey(name: 'one_word') String get oneWord;/// 相手の技術スタック（バックエンド: tech_stack）。
/// カンマ / スラッシュ / 空白などで区切られた文字列を想定。
/// サーバーが返さない場合は空文字で、共通タグ表示側では非表示扱いになる。
@JsonKey(name: 'tech_stack') String get techStack;
/// Create a copy of EncounteredUserInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncounteredUserInfoCopyWith<EncounteredUserInfo> get copyWith => _$EncounteredUserInfoCopyWithImpl<EncounteredUserInfo>(this as EncounteredUserInfo, _$identity);

  /// Serializes this EncounteredUserInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncounteredUserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.oneWord, oneWord) || other.oneWord == oneWord)&&(identical(other.techStack, techStack) || other.techStack == techStack));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl,oneWord,techStack);

@override
String toString() {
  return 'EncounteredUserInfo(id: $id, name: $name, iconUrl: $iconUrl, oneWord: $oneWord, techStack: $techStack)';
}


}

/// @nodoc
abstract mixin class $EncounteredUserInfoCopyWith<$Res>  {
  factory $EncounteredUserInfoCopyWith(EncounteredUserInfo value, $Res Function(EncounteredUserInfo) _then) = _$EncounteredUserInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'icon_url') String iconUrl,@JsonKey(name: 'one_word') String oneWord,@JsonKey(name: 'tech_stack') String techStack
});




}
/// @nodoc
class _$EncounteredUserInfoCopyWithImpl<$Res>
    implements $EncounteredUserInfoCopyWith<$Res> {
  _$EncounteredUserInfoCopyWithImpl(this._self, this._then);

  final EncounteredUserInfo _self;
  final $Res Function(EncounteredUserInfo) _then;

/// Create a copy of EncounteredUserInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconUrl = null,Object? oneWord = null,Object? techStack = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,oneWord: null == oneWord ? _self.oneWord : oneWord // ignore: cast_nullable_to_non_nullable
as String,techStack: null == techStack ? _self.techStack : techStack // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EncounteredUserInfo].
extension EncounteredUserInfoPatterns on EncounteredUserInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncounteredUserInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncounteredUserInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncounteredUserInfo value)  $default,){
final _that = this;
switch (_that) {
case _EncounteredUserInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncounteredUserInfo value)?  $default,){
final _that = this;
switch (_that) {
case _EncounteredUserInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'one_word')  String oneWord, @JsonKey(name: 'tech_stack')  String techStack)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncounteredUserInfo() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl,_that.oneWord,_that.techStack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'one_word')  String oneWord, @JsonKey(name: 'tech_stack')  String techStack)  $default,) {final _that = this;
switch (_that) {
case _EncounteredUserInfo():
return $default(_that.id,_that.name,_that.iconUrl,_that.oneWord,_that.techStack);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'one_word')  String oneWord, @JsonKey(name: 'tech_stack')  String techStack)?  $default,) {final _that = this;
switch (_that) {
case _EncounteredUserInfo() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl,_that.oneWord,_that.techStack);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EncounteredUserInfo implements EncounteredUserInfo {
  const _EncounteredUserInfo({required this.id, this.name = '???', @JsonKey(name: 'icon_url') this.iconUrl = '', @JsonKey(name: 'one_word') this.oneWord = '', @JsonKey(name: 'tech_stack') this.techStack = ''});
  factory _EncounteredUserInfo.fromJson(Map<String, dynamic> json) => _$EncounteredUserInfoFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'icon_url') final  String iconUrl;
@override@JsonKey(name: 'one_word') final  String oneWord;
/// 相手の技術スタック（バックエンド: tech_stack）。
/// カンマ / スラッシュ / 空白などで区切られた文字列を想定。
/// サーバーが返さない場合は空文字で、共通タグ表示側では非表示扱いになる。
@override@JsonKey(name: 'tech_stack') final  String techStack;

/// Create a copy of EncounteredUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncounteredUserInfoCopyWith<_EncounteredUserInfo> get copyWith => __$EncounteredUserInfoCopyWithImpl<_EncounteredUserInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EncounteredUserInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncounteredUserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.oneWord, oneWord) || other.oneWord == oneWord)&&(identical(other.techStack, techStack) || other.techStack == techStack));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl,oneWord,techStack);

@override
String toString() {
  return 'EncounteredUserInfo(id: $id, name: $name, iconUrl: $iconUrl, oneWord: $oneWord, techStack: $techStack)';
}


}

/// @nodoc
abstract mixin class _$EncounteredUserInfoCopyWith<$Res> implements $EncounteredUserInfoCopyWith<$Res> {
  factory _$EncounteredUserInfoCopyWith(_EncounteredUserInfo value, $Res Function(_EncounteredUserInfo) _then) = __$EncounteredUserInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'icon_url') String iconUrl,@JsonKey(name: 'one_word') String oneWord,@JsonKey(name: 'tech_stack') String techStack
});




}
/// @nodoc
class __$EncounteredUserInfoCopyWithImpl<$Res>
    implements _$EncounteredUserInfoCopyWith<$Res> {
  __$EncounteredUserInfoCopyWithImpl(this._self, this._then);

  final _EncounteredUserInfo _self;
  final $Res Function(_EncounteredUserInfo) _then;

/// Create a copy of EncounteredUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconUrl = null,Object? oneWord = null,Object? techStack = null,}) {
  return _then(_EncounteredUserInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,oneWord: null == oneWord ? _self.oneWord : oneWord // ignore: cast_nullable_to_non_nullable
as String,techStack: null == techStack ? _self.techStack : techStack // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
