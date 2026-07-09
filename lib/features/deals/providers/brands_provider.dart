import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'deals_provider.dart' show supabaseProvider;

part 'brands_provider.g.dart';

/// A brand shown in the "Utvalda Brands" section, with an optional logo.
///
/// [logoUrl] absent means the section falls back to a text badge for that
/// brand — never a broken image.
@immutable
class Brand {
  const Brand({required this.name, this.logoUrl});

  final String name;
  final String? logoUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Brand && other.name == name && other.logoUrl == logoUrl);

  @override
  int get hashCode => Object.hash(name, logoUrl);
}

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
@Riverpod(keepAlive: true)
Future<List<Brand>> brands(Ref ref) async {
  final supabase = ref.watch(supabaseProvider);

  final curated = await _fetchCuratedBrands(supabase);
  if (curated.isNotEmpty) return curated;

  final names = await _fetchUniqueBrandNamesFromProducts(supabase);
  final sorted = names.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return [for (final name in sorted) Brand(name: name)];
}

/// Reads the curated list. Returns an empty list (not an error) if the table
/// doesn't exist yet, so callers can fall through to the products-derived
/// list without special-casing "table missing" vs "table empty".
Future<List<Brand>> _fetchCuratedBrands(SupabaseClient supabase) async {
  try {
    final rows = await supabase
        .from('brand_logos')
        .select('brand, logo_url')
        .order('sort_order', ascending: true);
    return [
      for (final row in rows as List)
        if (row['brand'] != null)
          Brand(
            name: row['brand'] as String,
            logoUrl: row['logo_url'] as String?,
          ),
    ];
  } catch (_) {
    return const [];
  }
}

/// Prefers a `get_unique_brands` Postgres RPC (a single `SELECT DISTINCT
/// brand FROM products ...`) so we don't have to download every product row
/// just to list brand names. Falls back to a plain column select + client
/// side de-dupe if that RPC hasn't been created yet.
///
/// Suggested migration for the fast path:
/// ```sql
/// create or replace function get_unique_brands()
/// returns table (brand text) language sql stable as $$
///   select distinct brand from products
///   where brand is not null and brand <> '' and brand <> 'unknown';
/// $$;
/// ```
Future<Set<String>> _fetchUniqueBrandNamesFromProducts(
  SupabaseClient supabase,
) async {
  try {
    final rpcResult = await supabase.rpc('get_unique_brands');
    return _extractBrandNames(rpcResult as List);
  } on PostgrestException {
    final rows = await supabase.from('products').select('brand');
    return _extractBrandNames(rows as List);
  }
}

Set<String> _extractBrandNames(List<dynamic> rows) {
  final names = <String>{};
  for (final row in rows) {
    final raw = row is Map ? row['brand'] as String? : row as String?;
    final brand = raw?.trim();
    if (brand != null && brand.isNotEmpty && brand.toLowerCase() != 'unknown') {
      names.add(brand);
    }
  }
  return names;
}
