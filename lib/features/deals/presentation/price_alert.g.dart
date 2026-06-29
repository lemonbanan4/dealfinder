// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceAlert _$PriceAlertFromJson(Map<String, dynamic> json) => _PriceAlert(
  id: (json['id'] as num).toInt(),
  productId: json['product_id'] as String,
  userId: json['user_id'] as String,
  targetPrice: (json['target_price'] as num).toDouble(),
  productTitle: json['product_title'] as String,
  productUrl: json['product_url'] as String,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  latestPrice: (json['latest_price'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
);

Map<String, dynamic> _$PriceAlertToJson(_PriceAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'user_id': instance.userId,
      'target_price': instance.targetPrice,
      'product_title': instance.productTitle,
      'product_url': instance.productUrl,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'latest_price': instance.latestPrice,
      'currency': instance.currency,
    };
