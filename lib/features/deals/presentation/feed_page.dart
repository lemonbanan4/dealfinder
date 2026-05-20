import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repositories.dart' show currencyServiceProvider;
import '../../../widgets/app_logo.dart';
import '../../../widgets/deal_card.dart';
import '../../currency/domain/exchange_rates.dart';
import '../../currency/providers/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/deal.dart';
import '../providers/deals_provider.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(firestoreDealFeedProvider);
    final settings = ref.watch(appSettingsNotifierProvider);
    final ratesAsync = ref.watch(exchangeRatesNotifierProvider);
    final isRefreshing = feedAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isRefreshing
                ? null
                : () => ref.invalidate(firestoreDealFeedProvider),
            icon: isRefreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: feedAsync.when(
        loading: () => const _ShimmerGrid(),
        error: (err, _) => _ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(firestoreDealFeedProvider),
        ),
        data: (deals) {
          if (deals.isEmpty) {
            return _EmptyState(
              onRefresh: () => ref.invalidate(firestoreDealFeedProvider),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(firestoreDealFeedProvider),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(isWide ? 20 : 14),
                      sliver: isWide
                          ? SliverGrid.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 130,
                              ),
                              itemCount: deals.length,
                              itemBuilder: (context, index) =>
                                  _buildCard(context, ref, deals[index], settings.displayCurrency, ratesAsync),
                            )
                          : SliverList.separated(
                              itemCount: deals.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) =>
                                  _buildCard(context, ref, deals[index], settings.displayCurrency, ratesAsync),
                            ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Deal deal, String currency, AsyncValue<ExchangeRates> ratesAsync) {
    final displayPrice = ratesAsync.maybeWhen(
      data: (rates) => ref
          .read(currencyServiceProvider)
          .convert(deal.priceEur, currency, rates),
      orElse: () => deal.priceEur,
    );
    return DealCard(
      deal: deal,
      displayPrice: displayPrice,
      currency: currency,
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redirecting to merchant...'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      ),
    );
  }
}

// ─── Shimmer skeleton loading ─────────────────────────────────────────────────

class _ShimmerGrid extends StatefulWidget {
  const _ShimmerGrid();

  @override
  State<_ShimmerGrid> createState() => _ShimmerGridState();
}

class _ShimmerGridState extends State<_ShimmerGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.25, end: 0.6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        return AnimatedBuilder(
          animation: _opacity,
          builder: (context, _) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(isWide ? 20 : 14),
                sliver: isWide
                    ? SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 130,
                        ),
                        itemCount: 6,
                        itemBuilder: (_, _) =>
                            _SkeletonCard(opacity: _opacity.value),
                      )
                    : SliverList.separated(
                        itemCount: 5,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, _) =>
                            _SkeletonCard(opacity: _opacity.value),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final shimmer = const Color(0xFF272839).withAlpha((opacity * 255).round());

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF252638)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 130,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 110, color: shimmer),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 13,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 13,
                        width: 140,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 16,
                        width: 90,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty / Error states ─────────────────────────────────────────────────────

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
          Text(
            'No deals yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          const Text('Enable sources in Settings, then tap Refresh.'),
          const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
