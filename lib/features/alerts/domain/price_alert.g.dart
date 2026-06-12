// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceAlert _$PriceAlertFromJson(Map<String, dynamic> json) => _PriceAlert(
  id: json['id'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  time: DateTime.parse(json['time'] as String),
  isRead: json['isRead'] as bool? ?? false,
);

Map<String, dynamic> _$PriceAlertToJson(_PriceAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'time': instance.time.toIso8601String(),
      'isRead': instance.isRead,
    };
