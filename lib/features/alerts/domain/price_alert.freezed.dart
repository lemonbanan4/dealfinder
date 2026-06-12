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

 String get id; String get title; String get message; DateTime get time; bool get isRead;
/// Create a copy of PriceAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceAlertCopyWith<PriceAlert> get copyWith => _$PriceAlertCopyWithImpl<PriceAlert>(this as PriceAlert, _$identity);

  /// Serializes this PriceAlert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.time, time) || other.time == time)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,message,time,isRead);

@override
String toString() {
  return 'PriceAlert(id: $id, title: $title, message: $message, time: $time, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $PriceAlertCopyWith<$Res>  {
  factory $PriceAlertCopyWith(PriceAlert value, $Res Function(PriceAlert) _then) = _$PriceAlertCopyWithImpl;
@useResult
$Res call({
 String id, String title, String message, DateTime time, bool isRead
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? message = null,Object? time = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String message,  DateTime time,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceAlert() when $default != null:
return $default(_that.id,_that.title,_that.message,_that.time,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String message,  DateTime time,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _PriceAlert():
return $default(_that.id,_that.title,_that.message,_that.time,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String message,  DateTime time,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _PriceAlert() when $default != null:
return $default(_that.id,_that.title,_that.message,_that.time,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceAlert implements PriceAlert {
  const _PriceAlert({required this.id, required this.title, required this.message, required this.time, this.isRead = false});
  factory _PriceAlert.fromJson(Map<String, dynamic> json) => _$PriceAlertFromJson(json);

@override final  String id;
@override final  String title;
@override final  String message;
@override final  DateTime time;
@override@JsonKey() final  bool isRead;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.time, time) || other.time == time)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,message,time,isRead);

@override
String toString() {
  return 'PriceAlert(id: $id, title: $title, message: $message, time: $time, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$PriceAlertCopyWith<$Res> implements $PriceAlertCopyWith<$Res> {
  factory _$PriceAlertCopyWith(_PriceAlert value, $Res Function(_PriceAlert) _then) = __$PriceAlertCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String message, DateTime time, bool isRead
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? message = null,Object? time = null,Object? isRead = null,}) {
  return _then(_PriceAlert(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
