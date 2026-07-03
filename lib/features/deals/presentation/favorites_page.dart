import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/deal.dart';
import 'deal_details_page.dart';
import 'deals_notifier.dart';
import '../providers/favorites_provider.dart';
import '../../../widgets/deal_card.dart';

/// A provider that filters the deals and returns only the favorites.
final favoriteDealsProvider = Provider<List<Deal>>((ref) {
  final dealsState = ref
      .watch(dealsProvider('', DealSort.relevance))
      .asData
      ?.value;
  final allDeals = dealsState?.deals ?? [];
  final favoriteIds = ref.watch(favoritesProvider).value ?? {};

  if (favoriteIds.isEmpty || allDeals.isEmpty) {
    return [];
  }
  return allDeals.where((deal) => favoriteIds.contains(deal.id)).toList();
});

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteDeals = ref.watch(favoriteDealsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.invalidate(favoritesProvider);
          return ref.refresh(
            dealsProvider('', DealSort.relevance).future,
          );
        },
        child: favoriteDeals.isEmpty
            ? const Center(
                child: Text(
                  'You haven\'t saved any favorites yet.\nTap the ❤️ on a deal to save it!',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: favoriteDeals.length,
                itemBuilder: (context, index) {
                  final deal = favoriteDeals[index];
                  // Bug 2 fix: was missing required onTap — now navigates to detail page
                  return DealCard(
                    deal: deal,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DealDetailsPage(deal: deal),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
