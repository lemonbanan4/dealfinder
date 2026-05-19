// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Deal {

 String get id; String get title; double get priceEur; String get sourceName; String get url; String? get imageUrl; String? get originalCurrency; double? get originalPrice; DateTime get scrapedAt;
/// Create a copy of Deal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DealCopyWith<Deal> get copyWith => _$DealCopyWithImpl<Deal>(this as Deal, _$identity);

  /// Serializes this Deal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Deal&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceEur, priceEur) || other.priceEur == priceEur)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.url, url) || other.url == url)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.originalCurrency, originalCurrency) || other.originalCurrency == originalCurrency)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.scrapedAt, scrapedAt) || other.scrapedAt == scrapedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,priceEur,sourceName,url,imageUrl,originalCurrency,originalPrice,scrapedAt);

@override
String toString() {
  return 'Deal(id: $id, title: $title, priceEur: $priceEur, sourceName: $sourceName, url: $url, imageUrl: $imageUrl, originalCurrency: $originalCurrency, originalPrice: $originalPrice, scrapedAt: $scrapedAt)';
}


}

/// @nodoc
abstract mixin class $DealCopyWith<$Res>  {
  factory $DealCopyWith(Deal value, $Res Function(Deal) _then) = _$DealCopyWithImpl;
@useResult
$Res call({
 String id, String title, double priceEur, String sourceName, String url, String? imageUrl, String? originalCurrency, double? originalPrice, DateTime scrapedAt
});




}
/// @nodoc
class _$DealCopyWithImpl<$Res>
    implements $DealCopyWith<$Res> {
  _$DealCopyWithImpl(this._self, this._then);

  final Deal _self;
  final $Res Function(Deal) _then;

/// Create a copy of Deal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? priceEur = null,Object? sourceName = null,Object? url = null,Object? imageUrl = freezed,Object? originalCurrency = freezed,Object? originalPrice = freezed,Object? scrapedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceEur: null == priceEur ? _self.priceEur : priceEur // ignore: cast_nullable_to_non_nullable
as double,sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,originalCurrency: freezed == originalCurrency ? _self.originalCurrency : originalCurrency // ignore: cast_nullable_to_non_nullable
as String?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,scrapedAt: null == scrapedAt ? _self.scrapedAt : scrapedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Deal].
extension DealPatterns on Deal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Deal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Deal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Deal value)  $default,){
final _that = this;
switch (_that) {
case _Deal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Deal value)?  $default,){
final _that = this;
switch (_that) {
case _Deal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double priceEur,  String sourceName,  String url,  String? imageUrl,  String? originalCurrency,  double? originalPrice,  DateTime scrapedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Deal() when $default != null:
return $default(_that.id,_that.title,_that.priceEur,_that.sourceName,_that.url,_that.imageUrl,_that.originalCurrency,_that.originalPrice,_that.scrapedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double priceEur,  String sourceName,  String url,  String? imageUrl,  String? originalCurrency,  double? originalPrice,  DateTime scrapedAt)  $default,) {final _that = this;
switch (_that) {
case _Deal():
return $default(_that.id,_that.title,_that.priceEur,_that.sourceName,_that.url,_that.imageUrl,_that.originalCurrency,_that.originalPrice,_that.scrapedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double priceEur,  String sourceName,  String url,  String? imageUrl,  String? originalCurrency,  double? originalPrice,  DateTime scrapedAt)?  $default,) {final _that = this;
switch (_that) {
case _Deal() when $default != null:
return $default(_that.id,_that.title,_that.priceEur,_that.sourceName,_that.url,_that.imageUrl,_that.originalCurrency,_that.originalPrice,_that.scrapedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Deal implements Deal {
  const _Deal({required this.id, required this.title, required this.priceEur, required this.sourceName, required this.url, this.imageUrl, this.originalCurrency, this.originalPrice, required this.scrapedAt});
  factory _Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);

@override final  String id;
@override final  String title;
@override final  double priceEur;
@override final  String sourceName;
@override final  String url;
@override final  String? imageUrl;
@override final  String? originalCurrency;
@override final  double? originalPrice;
@override final  DateTime scrapedAt;

/// Create a copy of Deal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DealCopyWith<_Deal> get copyWith => __$DealCopyWithImpl<_Deal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deal&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceEur, priceEur) || other.priceEur == priceEur)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.url, url) || other.url == url)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.originalCurrency, originalCurrency) || other.originalCurrency == originalCurrency)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.scrapedAt, scrapedAt) || other.scrapedAt == scrapedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,priceEur,sourceName,url,imageUrl,originalCurrency,originalPrice,scrapedAt);

@override
String toString() {
  return 'Deal(id: $id, title: $title, priceEur: $priceEur, sourceName: $sourceName, url: $url, imageUrl: $imageUrl, originalCurrency: $originalCurrency, originalPrice: $originalPrice, scrapedAt: $scrapedAt)';
}


}

/// @nodoc
abstract mixin class _$DealCopyWith<$Res> implements $DealCopyWith<$Res> {
  factory _$DealCopyWith(_Deal value, $Res Function(_Deal) _then) = __$DealCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double priceEur, String sourceName, String url, String? imageUrl, String? originalCurrency, double? originalPrice, DateTime scrapedAt
});




}
/// @nodoc
class __$DealCopyWithImpl<$Res>
    implements _$DealCopyWith<$Res> {
  __$DealCopyWithImpl(this._self, this._then);

  final _Deal _self;
  final $Res Function(_Deal) _then;

/// Create a copy of Deal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? priceEur = null,Object? sourceName = null,Object? url = null,Object? imageUrl = freezed,Object? originalCurrency = freezed,Object? originalPrice = freezed,Object? scrapedAt = null,}) {
  return _then(_Deal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceEur: null == priceEur ? _self.priceEur : priceEur // ignore: cast_nullable_to_non_nullable
as double,sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,originalCurrency: freezed == originalCurrency ? _self.originalCurrency : originalCurrency // ignore: cast_nullable_to_non_nullable
as String?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,scrapedAt: null == scrapedAt ? _self.scrapedAt : scrapedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
