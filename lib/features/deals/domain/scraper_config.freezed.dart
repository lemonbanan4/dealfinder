// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scraper_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScraperConfig {

 String get id; String get name; String get baseUrl; String get listSelector; String get titleSelector; String get priceSelector; String get linkSelector; String? get imageSelector; String? get nextPageSelector; String get currencyCode; bool get isEnabled; String? get lastError; DateTime? get lastErrorAt;
/// Create a copy of ScraperConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScraperConfigCopyWith<ScraperConfig> get copyWith => _$ScraperConfigCopyWithImpl<ScraperConfig>(this as ScraperConfig, _$identity);

  /// Serializes this ScraperConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScraperConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.listSelector, listSelector) || other.listSelector == listSelector)&&(identical(other.titleSelector, titleSelector) || other.titleSelector == titleSelector)&&(identical(other.priceSelector, priceSelector) || other.priceSelector == priceSelector)&&(identical(other.linkSelector, linkSelector) || other.linkSelector == linkSelector)&&(identical(other.imageSelector, imageSelector) || other.imageSelector == imageSelector)&&(identical(other.nextPageSelector, nextPageSelector) || other.nextPageSelector == nextPageSelector)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.lastErrorAt, lastErrorAt) || other.lastErrorAt == lastErrorAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,listSelector,titleSelector,priceSelector,linkSelector,imageSelector,nextPageSelector,currencyCode,isEnabled,lastError,lastErrorAt);

@override
String toString() {
  return 'ScraperConfig(id: $id, name: $name, baseUrl: $baseUrl, listSelector: $listSelector, titleSelector: $titleSelector, priceSelector: $priceSelector, linkSelector: $linkSelector, imageSelector: $imageSelector, nextPageSelector: $nextPageSelector, currencyCode: $currencyCode, isEnabled: $isEnabled, lastError: $lastError, lastErrorAt: $lastErrorAt)';
}


}

/// @nodoc
abstract mixin class $ScraperConfigCopyWith<$Res>  {
  factory $ScraperConfigCopyWith(ScraperConfig value, $Res Function(ScraperConfig) _then) = _$ScraperConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name, String baseUrl, String listSelector, String titleSelector, String priceSelector, String linkSelector, String? imageSelector, String? nextPageSelector, String currencyCode, bool isEnabled, String? lastError, DateTime? lastErrorAt
});




}
/// @nodoc
class _$ScraperConfigCopyWithImpl<$Res>
    implements $ScraperConfigCopyWith<$Res> {
  _$ScraperConfigCopyWithImpl(this._self, this._then);

  final ScraperConfig _self;
  final $Res Function(ScraperConfig) _then;

/// Create a copy of ScraperConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? listSelector = null,Object? titleSelector = null,Object? priceSelector = null,Object? linkSelector = null,Object? imageSelector = freezed,Object? nextPageSelector = freezed,Object? currencyCode = null,Object? isEnabled = null,Object? lastError = freezed,Object? lastErrorAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,listSelector: null == listSelector ? _self.listSelector : listSelector // ignore: cast_nullable_to_non_nullable
as String,titleSelector: null == titleSelector ? _self.titleSelector : titleSelector // ignore: cast_nullable_to_non_nullable
as String,priceSelector: null == priceSelector ? _self.priceSelector : priceSelector // ignore: cast_nullable_to_non_nullable
as String,linkSelector: null == linkSelector ? _self.linkSelector : linkSelector // ignore: cast_nullable_to_non_nullable
as String,imageSelector: freezed == imageSelector ? _self.imageSelector : imageSelector // ignore: cast_nullable_to_non_nullable
as String?,nextPageSelector: freezed == nextPageSelector ? _self.nextPageSelector : nextPageSelector // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,lastErrorAt: freezed == lastErrorAt ? _self.lastErrorAt : lastErrorAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScraperConfig].
extension ScraperConfigPatterns on ScraperConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScraperConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScraperConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScraperConfig value)  $default,){
final _that = this;
switch (_that) {
case _ScraperConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScraperConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ScraperConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String listSelector,  String titleSelector,  String priceSelector,  String linkSelector,  String? imageSelector,  String? nextPageSelector,  String currencyCode,  bool isEnabled,  String? lastError,  DateTime? lastErrorAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScraperConfig() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.listSelector,_that.titleSelector,_that.priceSelector,_that.linkSelector,_that.imageSelector,_that.nextPageSelector,_that.currencyCode,_that.isEnabled,_that.lastError,_that.lastErrorAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String baseUrl,  String listSelector,  String titleSelector,  String priceSelector,  String linkSelector,  String? imageSelector,  String? nextPageSelector,  String currencyCode,  bool isEnabled,  String? lastError,  DateTime? lastErrorAt)  $default,) {final _that = this;
switch (_that) {
case _ScraperConfig():
return $default(_that.id,_that.name,_that.baseUrl,_that.listSelector,_that.titleSelector,_that.priceSelector,_that.linkSelector,_that.imageSelector,_that.nextPageSelector,_that.currencyCode,_that.isEnabled,_that.lastError,_that.lastErrorAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String baseUrl,  String listSelector,  String titleSelector,  String priceSelector,  String linkSelector,  String? imageSelector,  String? nextPageSelector,  String currencyCode,  bool isEnabled,  String? lastError,  DateTime? lastErrorAt)?  $default,) {final _that = this;
switch (_that) {
case _ScraperConfig() when $default != null:
return $default(_that.id,_that.name,_that.baseUrl,_that.listSelector,_that.titleSelector,_that.priceSelector,_that.linkSelector,_that.imageSelector,_that.nextPageSelector,_that.currencyCode,_that.isEnabled,_that.lastError,_that.lastErrorAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScraperConfig implements ScraperConfig {
  const _ScraperConfig({required this.id, required this.name, required this.baseUrl, required this.listSelector, required this.titleSelector, required this.priceSelector, required this.linkSelector, this.imageSelector, this.nextPageSelector, this.currencyCode = 'EUR', this.isEnabled = true, this.lastError, this.lastErrorAt});
  factory _ScraperConfig.fromJson(Map<String, dynamic> json) => _$ScraperConfigFromJson(json);

@override final  String id;
@override final  String name;
@override final  String baseUrl;
@override final  String listSelector;
@override final  String titleSelector;
@override final  String priceSelector;
@override final  String linkSelector;
@override final  String? imageSelector;
@override final  String? nextPageSelector;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  bool isEnabled;
@override final  String? lastError;
@override final  DateTime? lastErrorAt;

/// Create a copy of ScraperConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScraperConfigCopyWith<_ScraperConfig> get copyWith => __$ScraperConfigCopyWithImpl<_ScraperConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScraperConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScraperConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.listSelector, listSelector) || other.listSelector == listSelector)&&(identical(other.titleSelector, titleSelector) || other.titleSelector == titleSelector)&&(identical(other.priceSelector, priceSelector) || other.priceSelector == priceSelector)&&(identical(other.linkSelector, linkSelector) || other.linkSelector == linkSelector)&&(identical(other.imageSelector, imageSelector) || other.imageSelector == imageSelector)&&(identical(other.nextPageSelector, nextPageSelector) || other.nextPageSelector == nextPageSelector)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.lastErrorAt, lastErrorAt) || other.lastErrorAt == lastErrorAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUrl,listSelector,titleSelector,priceSelector,linkSelector,imageSelector,nextPageSelector,currencyCode,isEnabled,lastError,lastErrorAt);

@override
String toString() {
  return 'ScraperConfig(id: $id, name: $name, baseUrl: $baseUrl, listSelector: $listSelector, titleSelector: $titleSelector, priceSelector: $priceSelector, linkSelector: $linkSelector, imageSelector: $imageSelector, nextPageSelector: $nextPageSelector, currencyCode: $currencyCode, isEnabled: $isEnabled, lastError: $lastError, lastErrorAt: $lastErrorAt)';
}


}

/// @nodoc
abstract mixin class _$ScraperConfigCopyWith<$Res> implements $ScraperConfigCopyWith<$Res> {
  factory _$ScraperConfigCopyWith(_ScraperConfig value, $Res Function(_ScraperConfig) _then) = __$ScraperConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String baseUrl, String listSelector, String titleSelector, String priceSelector, String linkSelector, String? imageSelector, String? nextPageSelector, String currencyCode, bool isEnabled, String? lastError, DateTime? lastErrorAt
});




}
/// @nodoc
class __$ScraperConfigCopyWithImpl<$Res>
    implements _$ScraperConfigCopyWith<$Res> {
  __$ScraperConfigCopyWithImpl(this._self, this._then);

  final _ScraperConfig _self;
  final $Res Function(_ScraperConfig) _then;

/// Create a copy of ScraperConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? baseUrl = null,Object? listSelector = null,Object? titleSelector = null,Object? priceSelector = null,Object? linkSelector = null,Object? imageSelector = freezed,Object? nextPageSelector = freezed,Object? currencyCode = null,Object? isEnabled = null,Object? lastError = freezed,Object? lastErrorAt = freezed,}) {
  return _then(_ScraperConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,listSelector: null == listSelector ? _self.listSelector : listSelector // ignore: cast_nullable_to_non_nullable
as String,titleSelector: null == titleSelector ? _self.titleSelector : titleSelector // ignore: cast_nullable_to_non_nullable
as String,priceSelector: null == priceSelector ? _self.priceSelector : priceSelector // ignore: cast_nullable_to_non_nullable
as String,linkSelector: null == linkSelector ? _self.linkSelector : linkSelector // ignore: cast_nullable_to_non_nullable
as String,imageSelector: freezed == imageSelector ? _self.imageSelector : imageSelector // ignore: cast_nullable_to_non_nullable
as String?,nextPageSelector: freezed == nextPageSelector ? _self.nextPageSelector : nextPageSelector // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,lastErrorAt: freezed == lastErrorAt ? _self.lastErrorAt : lastErrorAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
