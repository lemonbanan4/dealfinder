// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brands_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The "Utvalda Brands" (featured brands) list.
///
/// Primary source: a curated `brand_logos` table — this is a hand-picked,
/// on-brand set (the reference design shows ~7 recognizable logos, not every
/// distinct string in the catalog), ordered by `sort_order`.
///
/// Fallback: distinct `products.brand` values, for when `brand_logos` hasn't
/// been created/seeded yet. As of writing, live `products.brand` values are
/// almost entirely `"unknown"`/`null` (the scraper doesn't populate real
/// brand names yet), so this fallback will return an empty list until either
/// the scraper is fixed or `brand_logos` is seeded — see the SQL below.
///
/// Suggested setup:
/// ```sql
/// create table if not exists brand_logos (
///   brand text primary key,
///   logo_url text not null,
///   sort_order int not null default 0
/// );
///
/// insert into brand_logos (brand, logo_url, sort_order) values
///   ('Acer',    'https://cdn.simpleicons.org/acer/ffffff',    0),
///   ('Predator', null, 1), -- no icon available; renders as a text badge
///   ('Samsung', 'https://cdn.simpleicons.org/samsung/ffffff', 2),
///   ('Sony',    'https://cdn.simpleicons.org/sony/ffffff',    3),
///   ('Asus',    'https://cdn.simpleicons.org/asus/ffffff',    4),
///   ('Lenovo',  'https://cdn.simpleicons.org/lenovo/ffffff',  5),
///   ('HP',      'https://cdn.simpleicons.org/hp/ffffff',      6),
///   ('Dell',    'https://cdn.simpleicons.org/dell/ffffff',    7),
///   ('JBL',     'https://cdn.simpleicons.org/jbl/ffffff',     8),
///   ('Bosch',   'https://cdn.simpleicons.org/bosch/ffffff',   9);
/// ```
/// All white/monochrome (`/ffffff`) is deliberate, not a placeholder: it's
/// the classic muted-logo "trusted by" treatment (Stripe/Vercel/Linear-style)
/// that `BrandLogosSection` brightens on hover, and — empirically, tested
/// against this exact CDN — the only variant that reliably renders for every
/// brand here. Custom per-brand hex colors were tried first; Samsung's and
/// Lenovo's colored SVG variants specifically failed to render via
/// `flutter_svg` (silent decode failure, falling back to the text badge)
/// despite being valid, fetchable SVG — likely a `flutter_svg` path-parser
/// edge case with those two specific icons. Clearbit's logo API
/// (`logo.clearbit.com`) was also tried as a colored-raster alternative; it
/// no longer resolves at all (`ERR_NAME_NOT_RESOLVED`), i.e. the service has
/// been shut down. Re-test before reintroducing custom colors.
/// (Row 2 has a null `logo_url` — adjust the column/insert to allow it, or
/// just omit brands with no icon and rely on the text-badge fallback.)
///
/// Kept alive for the app session — this list changes rarely, so there's no
/// need to refetch every time the section scrolls back into view.

@ProviderFor(brands)
final brandsProvider = BrandsProvider._();

/// The "Utvalda Brands" (featured brands) list.
///
/// Primary source: a curated `brand_logos` table — this is a hand-picked,
/// on-brand set (the reference design shows ~7 recognizable logos, not every
/// distinct string in the catalog), ordered by `sort_order`.
///
/// Fallback: distinct `products.brand` values, for when `brand_logos` hasn't
/// been created/seeded yet. As of writing, live `products.brand` values are
/// almost entirely `"unknown"`/`null` (the scraper doesn't populate real
/// brand names yet), so this fallback will return an empty list until either
/// the scraper is fixed or `brand_logos` is seeded — see the SQL below.
///
/// Suggested setup:
/// ```sql
/// create table if not exists brand_logos (
///   brand text primary key,
///   logo_url text not null,
///   sort_order int not null default 0
/// );
///
/// insert into brand_logos (brand, logo_url, sort_order) values
///   ('Acer',    'https://cdn.simpleicons.org/acer/ffffff',    0),
///   ('Predator', null, 1), -- no icon available; renders as a text badge
///   ('Samsung', 'https://cdn.simpleicons.org/samsung/ffffff', 2),
///   ('Sony',    'https://cdn.simpleicons.org/sony/ffffff',    3),
///   ('Asus',    'https://cdn.simpleicons.org/asus/ffffff',    4),
///   ('Lenovo',  'https://cdn.simpleicons.org/lenovo/ffffff',  5),
///   ('HP',      'https://cdn.simpleicons.org/hp/ffffff',      6),
///   ('Dell',    'https://cdn.simpleicons.org/dell/ffffff',    7),
///   ('JBL',     'https://cdn.simpleicons.org/jbl/ffffff',     8),
///   ('Bosch',   'https://cdn.simpleicons.org/bosch/ffffff',   9);
/// ```
/// All white/monochrome (`/ffffff`) is deliberate, not a placeholder: it's
/// the classic muted-logo "trusted by" treatment (Stripe/Vercel/Linear-style)
/// that `BrandLogosSection` brightens on hover, and — empirically, tested
/// against this exact CDN — the only variant that reliably renders for every
/// brand here. Custom per-brand hex colors were tried first; Samsung's and
/// Lenovo's colored SVG variants specifically failed to render via
/// `flutter_svg` (silent decode failure, falling back to the text badge)
/// despite being valid, fetchable SVG — likely a `flutter_svg` path-parser
/// edge case with those two specific icons. Clearbit's logo API
/// (`logo.clearbit.com`) was also tried as a colored-raster alternative; it
/// no longer resolves at all (`ERR_NAME_NOT_RESOLVED`), i.e. the service has
/// been shut down. Re-test before reintroducing custom colors.
/// (Row 2 has a null `logo_url` — adjust the column/insert to allow it, or
/// just omit brands with no icon and rely on the text-badge fallback.)
///
/// Kept alive for the app session — this list changes rarely, so there's no
/// need to refetch every time the section scrolls back into view.

final class BrandsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Brand>>,
          List<Brand>,
          FutureOr<List<Brand>>
        >
    with $FutureModifier<List<Brand>>, $FutureProvider<List<Brand>> {
  /// The "Utvalda Brands" (featured brands) list.
  ///
  /// Primary source: a curated `brand_logos` table — this is a hand-picked,
  /// on-brand set (the reference design shows ~7 recognizable logos, not every
  /// distinct string in the catalog), ordered by `sort_order`.
  ///
  /// Fallback: distinct `products.brand` values, for when `brand_logos` hasn't
  /// been created/seeded yet. As of writing, live `products.brand` values are
  /// almost entirely `"unknown"`/`null` (the scraper doesn't populate real
  /// brand names yet), so this fallback will return an empty list until either
  /// the scraper is fixed or `brand_logos` is seeded — see the SQL below.
  ///
  /// Suggested setup:
  /// ```sql
  /// create table if not exists brand_logos (
  ///   brand text primary key,
  ///   logo_url text not null,
  ///   sort_order int not null default 0
  /// );
  ///
  /// insert into brand_logos (brand, logo_url, sort_order) values
  ///   ('Acer',    'https://cdn.simpleicons.org/acer/ffffff',    0),
  ///   ('Predator', null, 1), -- no icon available; renders as a text badge
  ///   ('Samsung', 'https://cdn.simpleicons.org/samsung/ffffff', 2),
  ///   ('Sony',    'https://cdn.simpleicons.org/sony/ffffff',    3),
  ///   ('Asus',    'https://cdn.simpleicons.org/asus/ffffff',    4),
  ///   ('Lenovo',  'https://cdn.simpleicons.org/lenovo/ffffff',  5),
  ///   ('HP',      'https://cdn.simpleicons.org/hp/ffffff',      6),
  ///   ('Dell',    'https://cdn.simpleicons.org/dell/ffffff',    7),
  ///   ('JBL',     'https://cdn.simpleicons.org/jbl/ffffff',     8),
  ///   ('Bosch',   'https://cdn.simpleicons.org/bosch/ffffff',   9);
  /// ```
  /// All white/monochrome (`/ffffff`) is deliberate, not a placeholder: it's
  /// the classic muted-logo "trusted by" treatment (Stripe/Vercel/Linear-style)
  /// that `BrandLogosSection` brightens on hover, and — empirically, tested
  /// against this exact CDN — the only variant that reliably renders for every
  /// brand here. Custom per-brand hex colors were tried first; Samsung's and
  /// Lenovo's colored SVG variants specifically failed to render via
  /// `flutter_svg` (silent decode failure, falling back to the text badge)
  /// despite being valid, fetchable SVG — likely a `flutter_svg` path-parser
  /// edge case with those two specific icons. Clearbit's logo API
  /// (`logo.clearbit.com`) was also tried as a colored-raster alternative; it
  /// no longer resolves at all (`ERR_NAME_NOT_RESOLVED`), i.e. the service has
  /// been shut down. Re-test before reintroducing custom colors.
  /// (Row 2 has a null `logo_url` — adjust the column/insert to allow it, or
  /// just omit brands with no icon and rely on the text-badge fallback.)
  ///
  /// Kept alive for the app session — this list changes rarely, so there's no
  /// need to refetch every time the section scrolls back into view.
  BrandsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandsHash();

  @$internal
  @override
  $FutureProviderElement<List<Brand>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Brand>> create(Ref ref) {
    return brands(ref);
  }
}

String _$brandsHash() => r'de44061325c241259e69f465f9bb4d424d05cee4';
