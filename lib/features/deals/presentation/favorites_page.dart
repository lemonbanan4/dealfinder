import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/glass_colors.dart';
import '../domain/deal.dart';
import '../providers/deals_provider.dart';
import '../providers/favorites_provider.dart';
import 'deal_slivers.dart';

/// The user's saved deals, filtered from the same catalog the main feed
/// uses ([dealFeedProvider]) rather than a separate fetch — favoriting a
/// deal only ever stores its id (see `FavoritesNotifier`), so the full deal
/// data still has to come from the feed's own cache.
final favoriteDealsProvider = Provider<List<Deal>>((ref) {
  final allDeals = ref.watch(dealFeedProvider).asData?.value ?? const [];
  final favoriteIds = ref.watch(favoritesProvider).value ?? const {};
  if (favoriteIds.isEmpty || allDeals.isEmpty) return const [];
  return allDeals.where((deal) => favoriteIds.contains(deal.id)).toList();
});

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesAsync = ref.watch(favoritesProvider);
    final dealFeedAsync = ref.watch(dealFeedProvider);
    final favoriteDeals = ref.watch(favoriteDealsProvider);

    final isLoading =
        (favoritesAsync.isLoading && !favoritesAsync.hasValue) ||
        (dealFeedAsync.isLoading && !dealFeedAsync.hasValue);

    return Scaffold(
      backgroundColor: GlassColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(l10n.myFavoritesTitle),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.invalidate(favoritesProvider);
          await ref.read(dealFeedProvider.notifier).refresh();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoriteDeals.isEmpty
            ? _EmptyFavorites(message: l10n.noFavoritesYet)
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: DealsSliver(
                      deals: favoriteDeals,
                      onFavoriteTap: (deal) => ref
                          .read(favoritesProvider.notifier)
                          .handleFavoriteTap(context, deal),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Scrollable even when short, so RefreshIndicator's pull-to-refresh
      // still works on an empty list.
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: GlassColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: GlassColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
