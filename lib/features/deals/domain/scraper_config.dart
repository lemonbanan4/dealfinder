import 'package:freezed_annotation/freezed_annotation.dart';

part 'scraper_config.freezed.dart';
part 'scraper_config.g.dart';

@freezed
abstract class ScraperConfig with _$ScraperConfig {
  const factory ScraperConfig({
    required String id,
    required String name,
    required String baseUrl,
    required String listSelector,
    required String titleSelector,
    required String priceSelector,
    required String linkSelector,
    String? imageSelector,
    String? nextPageSelector,
    @Default('EUR') String currencyCode,
    @Default(true) bool isEnabled,
  }) = _ScraperConfig;

  factory ScraperConfig.fromJson(Map<String, dynamic> json) =>
      _$ScraperConfigFromJson(json);
}
