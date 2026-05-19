// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

 String get displayCurrency; List<String> get enabledSourceIds; int get refreshIntervalMinutes; bool get notificationsEnabled;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.displayCurrency, displayCurrency) || other.displayCurrency == displayCurrency)&&const DeepCollectionEquality().equals(other.enabledSourceIds, enabledSourceIds)&&(identical(other.refreshIntervalMinutes, refreshIntervalMinutes) || other.refreshIntervalMinutes == refreshIntervalMinutes)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayCurrency,const DeepCollectionEquality().hash(enabledSourceIds),refreshIntervalMinutes,notificationsEnabled);

@override
String toString() {
  return 'AppSettings(displayCurrency: $displayCurrency, enabledSourceIds: $enabledSourceIds, refreshIntervalMinutes: $refreshIntervalMinutes, notificationsEnabled: $notificationsEnabled)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 String displayCurrency, List<String> enabledSourceIds, int refreshIntervalMinutes, bool notificationsEnabled
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayCurrency = null,Object? enabledSourceIds = null,Object? refreshIntervalMinutes = null,Object? notificationsEnabled = null,}) {
  return _then(_self.copyWith(
displayCurrency: null == displayCurrency ? _self.displayCurrency : displayCurrency // ignore: cast_nullable_to_non_nullable
as String,enabledSourceIds: null == enabledSourceIds ? _self.enabledSourceIds : enabledSourceIds // ignore: cast_nullable_to_non_nullable
as List<String>,refreshIntervalMinutes: null == refreshIntervalMinutes ? _self.refreshIntervalMinutes : refreshIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayCurrency,  List<String> enabledSourceIds,  int refreshIntervalMinutes,  bool notificationsEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.displayCurrency,_that.enabledSourceIds,_that.refreshIntervalMinutes,_that.notificationsEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayCurrency,  List<String> enabledSourceIds,  int refreshIntervalMinutes,  bool notificationsEnabled)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.displayCurrency,_that.enabledSourceIds,_that.refreshIntervalMinutes,_that.notificationsEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayCurrency,  List<String> enabledSourceIds,  int refreshIntervalMinutes,  bool notificationsEnabled)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.displayCurrency,_that.enabledSourceIds,_that.refreshIntervalMinutes,_that.notificationsEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({this.displayCurrency = 'NOK', final  List<String> enabledSourceIds = const [], this.refreshIntervalMinutes = 30, this.notificationsEnabled = true}): _enabledSourceIds = enabledSourceIds;
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@JsonKey() final  String displayCurrency;
 final  List<String> _enabledSourceIds;
@override@JsonKey() List<String> get enabledSourceIds {
  if (_enabledSourceIds is EqualUnmodifiableListView) return _enabledSourceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_enabledSourceIds);
}

@override@JsonKey() final  int refreshIntervalMinutes;
@override@JsonKey() final  bool notificationsEnabled;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.displayCurrency, displayCurrency) || other.displayCurrency == displayCurrency)&&const DeepCollectionEquality().equals(other._enabledSourceIds, _enabledSourceIds)&&(identical(other.refreshIntervalMinutes, refreshIntervalMinutes) || other.refreshIntervalMinutes == refreshIntervalMinutes)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayCurrency,const DeepCollectionEquality().hash(_enabledSourceIds),refreshIntervalMinutes,notificationsEnabled);

@override
String toString() {
  return 'AppSettings(displayCurrency: $displayCurrency, enabledSourceIds: $enabledSourceIds, refreshIntervalMinutes: $refreshIntervalMinutes, notificationsEnabled: $notificationsEnabled)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 String displayCurrency, List<String> enabledSourceIds, int refreshIntervalMinutes, bool notificationsEnabled
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayCurrency = null,Object? enabledSourceIds = null,Object? refreshIntervalMinutes = null,Object? notificationsEnabled = null,}) {
  return _then(_AppSettings(
displayCurrency: null == displayCurrency ? _self.displayCurrency : displayCurrency // ignore: cast_nullable_to_non_nullable
as String,enabledSourceIds: null == enabledSourceIds ? _self._enabledSourceIds : enabledSourceIds // ignore: cast_nullable_to_non_nullable
as List<String>,refreshIntervalMinutes: null == refreshIntervalMinutes ? _self.refreshIntervalMinutes : refreshIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
