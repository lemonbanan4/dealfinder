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

@JsonKey(name: 'product_id', defaultValue: 'unknown') String get id;@JsonKey(defaultValue: 'No Title') String get title;@JsonKey(name: 'tracking_url', defaultValue: '') String get url;@JsonKey(name: 'feed_region', defaultValue: 'Unknown') String get source;@JsonKey(name: 'price', defaultValue: 0.0) double get currentPrice;@JsonKey(defaultValue: 'SEK') String get currency;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'retail_price') double? get originalPrice;
/// Create a copy of Deal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DealCopyWith<Deal> get copyWith => _$DealCopyWithImpl<Deal>(this as Deal, _$identity);

  /// Serializes this Deal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Deal&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.source, source) || other.source == source)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,source,currentPrice,currency,imageUrl,originalPrice);

@override
String toString() {
  return 'Deal(id: $id, title: $title, url: $url, source: $source, currentPrice: $currentPrice, currency: $currency, imageUrl: $imageUrl, originalPrice: $originalPrice)';
}


}

/// @nodoc
abstract mixin class $DealCopyWith<$Res>  {
  factory $DealCopyWith(Deal value, $Res Function(Deal) _then) = _$DealCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'product_id', defaultValue: 'unknown') String id,@JsonKey(defaultValue: 'No Title') String title,@JsonKey(name: 'tracking_url', defaultValue: '') String url,@JsonKey(name: 'feed_region', defaultValue: 'Unknown') String source,@JsonKey(name: 'price', defaultValue: 0.0) double currentPrice,@JsonKey(defaultValue: 'SEK') String currency,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'retail_price') double? originalPrice
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? url = null,Object? source = null,Object? currentPrice = null,Object? currency = null,Object? imageUrl = freezed,Object? originalPrice = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id', defaultValue: 'unknown')  String id, @JsonKey(defaultValue: 'No Title')  String title, @JsonKey(name: 'tracking_url', defaultValue: '')  String url, @JsonKey(name: 'feed_region', defaultValue: 'Unknown')  String source, @JsonKey(name: 'price', defaultValue: 0.0)  double currentPrice, @JsonKey(defaultValue: 'SEK')  String currency, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'retail_price')  double? originalPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Deal() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.source,_that.currentPrice,_that.currency,_that.imageUrl,_that.originalPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id', defaultValue: 'unknown')  String id, @JsonKey(defaultValue: 'No Title')  String title, @JsonKey(name: 'tracking_url', defaultValue: '')  String url, @JsonKey(name: 'feed_region', defaultValue: 'Unknown')  String source, @JsonKey(name: 'price', defaultValue: 0.0)  double currentPrice, @JsonKey(defaultValue: 'SEK')  String currency, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'retail_price')  double? originalPrice)  $default,) {final _that = this;
switch (_that) {
case _Deal():
return $default(_that.id,_that.title,_that.url,_that.source,_that.currentPrice,_that.currency,_that.imageUrl,_that.originalPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'product_id', defaultValue: 'unknown')  String id, @JsonKey(defaultValue: 'No Title')  String title, @JsonKey(name: 'tracking_url', defaultValue: '')  String url, @JsonKey(name: 'feed_region', defaultValue: 'Unknown')  String source, @JsonKey(name: 'price', defaultValue: 0.0)  double currentPrice, @JsonKey(defaultValue: 'SEK')  String currency, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'retail_price')  double? originalPrice)?  $default,) {final _that = this;
switch (_that) {
case _Deal() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.source,_that.currentPrice,_that.currency,_that.imageUrl,_that.originalPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Deal implements Deal {
  const _Deal({@JsonKey(name: 'product_id', defaultValue: 'unknown') required this.id, @JsonKey(defaultValue: 'No Title') required this.title, @JsonKey(name: 'tracking_url', defaultValue: '') required this.url, @JsonKey(name: 'feed_region', defaultValue: 'Unknown') required this.source, @JsonKey(name: 'price', defaultValue: 0.0) required this.currentPrice, @JsonKey(defaultValue: 'SEK') required this.currency, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'retail_price') this.originalPrice});
  factory _Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);

@override@JsonKey(name: 'product_id', defaultValue: 'unknown') final  String id;
@override@JsonKey(defaultValue: 'No Title') final  String title;
@override@JsonKey(name: 'tracking_url', defaultValue: '') final  String url;
@override@JsonKey(name: 'feed_region', defaultValue: 'Unknown') final  String source;
@override@JsonKey(name: 'price', defaultValue: 0.0) final  double currentPrice;
@override@JsonKey(defaultValue: 'SEK') final  String currency;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'retail_price') final  double? originalPrice;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deal&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.source, source) || other.source == source)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,source,currentPrice,currency,imageUrl,originalPrice);

@override
String toString() {
  return 'Deal(id: $id, title: $title, url: $url, source: $source, currentPrice: $currentPrice, currency: $currency, imageUrl: $imageUrl, originalPrice: $originalPrice)';
}


}

/// @nodoc
abstract mixin class _$DealCopyWith<$Res> implements $DealCopyWith<$Res> {
  factory _$DealCopyWith(_Deal value, $Res Function(_Deal) _then) = __$DealCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'product_id', defaultValue: 'unknown') String id,@JsonKey(defaultValue: 'No Title') String title,@JsonKey(name: 'tracking_url', defaultValue: '') String url,@JsonKey(name: 'feed_region', defaultValue: 'Unknown') String source,@JsonKey(name: 'price', defaultValue: 0.0) double currentPrice,@JsonKey(defaultValue: 'SEK') String currency,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'retail_price') double? originalPrice
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? url = null,Object? source = null,Object? currentPrice = null,Object? currency = null,Object? imageUrl = freezed,Object? originalPrice = freezed,}) {
  return _then(_Deal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
