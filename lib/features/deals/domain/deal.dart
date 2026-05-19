import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal.freezed.dart';
part 'deal.g.dart';

@freezed
class Deal with _$Deal {
  const factory Deal({
    required String id,
    required String title,
    required double priceEur,
    required String sourceName,
    required String url,
    String? imageUrl,
    String? originalCurrency,
    double? originalPrice,
    required DateTime scrapedAt,
  }) = _Deal;

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);
}
