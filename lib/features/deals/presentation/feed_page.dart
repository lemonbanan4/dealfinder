import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repositories.dart';
import '../../../widgets/deal_card.dart';
import '../../currency/providers/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/deals_provider.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(dealFeedNotifierProvider);
    final settings = ref.watch(appSettingsNotifierProvider);
    final ratesAsync = ref.watch(exchangeRatesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal Feed'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: feedAsync.isLoading
                ? null
                : () => ref.read(dealFeedNotifierProvider.notifier).refresh(),
            icon: feedAsync.isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: feedAsync.when(
        loading: () => const _LoadingList(),
        error: (err, _) => _ErrorState(
          message: err.toString(),
          onRetry: () => ref.read(dealFeedNotifierProvider.notifier).refresh(),
        ),
        data: (deals) {
          if (deals.isEmpty) {
            return _EmptyState(
              onRefresh: () =>
                  ref.read(dealFeedNotifierProvider.notifier).refresh(),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(dealFeedNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
                final displayPrice = ratesAsync.maybeWhen(
                  data: (rates) => ref
                      .read(currencyServiceProvider)
                      .convert(deal.priceEur, settings.displayCurrency, rates),
                  orElse: () => deal.priceEur,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DealCard(
                    deal: deal,
                    displayPrice: displayPrice,
                    currency: settings.displayCurrency,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 140, color: color),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, color: color),
                const SizedBox(height: 6),
                Container(height: 14, width: 100, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront_outlined, size: 64),
          const SizedBox(height: 16),
          Text('No deals yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Enable sources in Settings, then tap Refresh.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh now'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
