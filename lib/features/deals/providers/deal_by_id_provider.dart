import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../domain/deal.dart';

part 'deal_by_id_provider.g.dart';

/// A single deal by its product id, for the crawlable `/products/:id` route
/// (see `ProductPage`) — unlike every other deal fetch in this app, this one
/// has no feed/catalog already in memory to look the id up in, since it's
/// meant to serve a cold page load (a shared link, a search result, a
/// browser refresh).
///
/// `/api/products?ids=` returns a bare array (see api.py) rather than the
/// `{items: [...]}` shape paginated/filtered endpoints use; `null` means the
/// id doesn't exist (removed deal, bad link) rather than a network failure,
/// which callers should still let surface as an error via [AsyncValue].
@riverpod
Future<Deal?> dealById(Ref ref, String id) async {
  final response = await apiGet('/api/products', queryParameters: {'ids': id});

  final items = json.decode(response.body) as List<dynamic>;
  if (items.isEmpty) return null;
  return Deal.fromJson(items.first as Map<String, dynamic>);
}
