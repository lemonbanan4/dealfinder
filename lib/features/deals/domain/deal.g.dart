// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deal _$DealFromJson(Map<String, dynamic> json) => _Deal(
  id: json['product_id'] as String,
  title: json['title'] as String,
  url: json['tracking_url'] as String,
  source: json['source'] as String,
  currentPrice: (json['price'] as num).toDouble(),
  currency: json['currency'] as String,
  imageUrl: json['image_url'] as String?,
  originalPrice: (json['retail_price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DealToJson(_Deal instance) => <String, dynamic>{
  'product_id': instance.id,
  'title': instance.title,
  'tracking_url': instance.url,
  'source': instance.source,
  'price': instance.currentPrice,
  'currency': instance.currency,
  'image_url': instance.imageUrl,
  'retail_price': instance.originalPrice,
};
