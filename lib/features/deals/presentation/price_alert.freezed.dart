// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceAlert {

 int get id;@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'target_price') double get targetPrice;@JsonKey(name: 'product_title') String get productTitle;@JsonKey(name: 'product_url') String get productUrl;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'latest_price') double? get latestPrice;@JsonKey(name: 'currency') String? get currency;
/// Create a copy of PriceAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceAlertCopyWith<PriceAlert> get copyWith => _$PriceAlertCopyWithImpl<PriceAlert>(this as PriceAlert, _$identity);

  /// Serializes this PriceAlert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.targetPrice, targetPrice) || other.targetPrice == targetPrice)&&(identical(other.productTitle, productTitle) || other.productTitle == productTitle)&&(identical(other.productUrl, productUrl) || other.productUrl == productUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.latestPrice, latestPrice) || other.latestPrice == latestPrice)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,userId,targetPrice,productTitle,productUrl,isActive,createdAt,latestPrice,currency);

@override
String toString() {
  return 'PriceAlert(id: $id, productId: $productId, userId: $userId, targetPrice: $targetPrice, productTitle: $productTitle, productUrl: $productUrl, isActive: $isActive, createdAt: $createdAt, latestPrice: $latestPrice, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $PriceAlertCopyWith<$Res>  {
  factory $PriceAlertCopyWith(PriceAlert value, $Res Function(PriceAlert) _then) = _$PriceAlertCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'target_price') double targetPrice,@JsonKey(name: 'product_title') String productTitle,@JsonKey(name: 'product_url') String productUrl,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'latest_price') double? latestPrice,@JsonKey(name: 'currency') String? currency
});




}
/// @nodoc
class _$PriceAlertCopyWithImpl<$Res>
    implements $PriceAlertCopyWith<$Res> {
  _$PriceAlertCopyWithImpl(this._self, this._then);

  final PriceAlert _self;
  final $Res Function(PriceAlert) _then;

/// Create a copy of PriceAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? userId = null,Object? targetPrice = null,Object? productTitle = null,Object? productUrl = null,Object? isActive = null,Object? createdAt = null,Object? latestPrice = freezed,Object? currency = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,targetPrice: null == targetPrice ? _self.targetPrice : targetPrice // ignore: cast_nullable_to_non_nullable
as double,productTitle: null == productTitle ? _self.productTitle : productTitle // ignore: cast_nullable_to_non_nullable
as String,productUrl: null == productUrl ? _self.productUrl : productUrl // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,latestPrice: freezed == latestPrice ? _self.latestPrice : latestPrice // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceAlert].
extension PriceAlertPatterns on PriceAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceAlert value)  $default,){
final _that = this;
switch (_that) {
case _PriceAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceAlert value)?  $default,){
final _that = this;
switch (_that) {
case _PriceAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'target_price')  double targetPrice, @JsonKey(name: 'product_title')  String productTitle, @JsonKey(name: 'product_url')  String productUrl, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'latest_price')  double? latestPrice, @JsonKey(name: 'currency')  String? currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceAlert() when $default != null:
return $default(_that.id,_that.productId,_that.userId,_that.targetPrice,_that.productTitle,_that.productUrl,_that.isActive,_that.createdAt,_that.latestPrice,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'target_price')  double targetPrice, @JsonKey(name: 'product_title')  String productTitle, @JsonKey(name: 'product_url')  String productUrl, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'latest_price')  double? latestPrice, @JsonKey(name: 'currency')  String? currency)  $default,) {final _that = this;
switch (_that) {
case _PriceAlert():
return $default(_that.id,_that.productId,_that.userId,_that.targetPrice,_that.productTitle,_that.productUrl,_that.isActive,_that.createdAt,_that.latestPrice,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'target_price')  double targetPrice, @JsonKey(name: 'product_title')  String productTitle, @JsonKey(name: 'product_url')  String productUrl, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'latest_price')  double? latestPrice, @JsonKey(name: 'currency')  String? currency)?  $default,) {final _that = this;
switch (_that) {
case _PriceAlert() when $default != null:
return $default(_that.id,_that.productId,_that.userId,_that.targetPrice,_that.productTitle,_that.productUrl,_that.isActive,_that.createdAt,_that.latestPrice,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceAlert implements PriceAlert {
  const _PriceAlert({required this.id, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'target_price') required this.targetPrice, @JsonKey(name: 'product_title') required this.productTitle, @JsonKey(name: 'product_url') required this.productUrl, @JsonKey(name: 'is_active') required this.isActive, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'latest_price') this.latestPrice, @JsonKey(name: 'currency') this.currency});
  factory _PriceAlert.fromJson(Map<String, dynamic> json) => _$PriceAlertFromJson(json);

@override final  int id;
@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'target_price') final  double targetPrice;
@override@JsonKey(name: 'product_title') final  String productTitle;
@override@JsonKey(name: 'product_url') final  String productUrl;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'latest_price') final  double? latestPrice;
@override@JsonKey(name: 'currency') final  String? currency;

/// Create a copy of PriceAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceAlertCopyWith<_PriceAlert> get copyWith => __$PriceAlertCopyWithImpl<_PriceAlert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceAlertToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.targetPrice, targetPrice) || other.targetPrice == targetPrice)&&(identical(other.productTitle, productTitle) || other.productTitle == productTitle)&&(identical(other.productUrl, productUrl) || other.productUrl == productUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.latestPrice, latestPrice) || other.latestPrice == latestPrice)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,userId,targetPrice,productTitle,productUrl,isActive,createdAt,latestPrice,currency);

@override
String toString() {
  return 'PriceAlert(id: $id, productId: $productId, userId: $userId, targetPrice: $targetPrice, productTitle: $productTitle, productUrl: $productUrl, isActive: $isActive, createdAt: $createdAt, latestPrice: $latestPrice, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$PriceAlertCopyWith<$Res> implements $PriceAlertCopyWith<$Res> {
  factory _$PriceAlertCopyWith(_PriceAlert value, $Res Function(_PriceAlert) _then) = __$PriceAlertCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'target_price') double targetPrice,@JsonKey(name: 'product_title') String productTitle,@JsonKey(name: 'product_url') String productUrl,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'latest_price') double? latestPrice,@JsonKey(name: 'currency') String? currency
});




}
/// @nodoc
class __$PriceAlertCopyWithImpl<$Res>
    implements _$PriceAlertCopyWith<$Res> {
  __$PriceAlertCopyWithImpl(this._self, this._then);

  final _PriceAlert _self;
  final $Res Function(_PriceAlert) _then;

/// Create a copy of PriceAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? userId = null,Object? targetPrice = null,Object? productTitle = null,Object? productUrl = null,Object? isActive = null,Object? createdAt = null,Object? latestPrice = freezed,Object? currency = freezed,}) {
  return _then(_PriceAlert(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,targetPrice: null == targetPrice ? _self.targetPrice : targetPrice // ignore: cast_nullable_to_non_nullable
as double,productTitle: null == productTitle ? _self.productTitle : productTitle // ignore: cast_nullable_to_non_nullable
as String,productUrl: null == productUrl ? _self.productUrl : productUrl // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,latestPrice: freezed == latestPrice ? _self.latestPrice : latestPrice // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
