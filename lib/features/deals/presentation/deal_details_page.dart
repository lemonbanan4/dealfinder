import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/seo/document_meta.dart';
import '../../../services/analytics_service.dart';
import '../../../theme/glass_colors.dart';
import '../../settings/presentation/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/favorites_provider.dart';
import '../domain/deal.dart';
import '../domain/store_display_names.dart';
import 'price_history_chart.dart';

const _productJsonLdId = 'product-jsonld';

class DealDetailsPage extends ConsumerStatefulWidget {
  const DealDetailsPage({super.key, required this.deal});

  final Deal deal;

  @override
  ConsumerState<DealDetailsPage> createState() => _DealDetailsPageState();
}

class _DealDetailsPageState extends ConsumerState<DealDetailsPage> {
  @override
  void initState() {
    super.initState();
    _syncProductMeta();
  }

  @override
  void didUpdateWidget(covariant DealDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deal.id != widget.deal.id) _syncProductMeta();
  }

  @override
  void dispose() {
    clearStructuredData(_productJsonLdId);
    super.dispose();
  }

  /// Product-page SEO meta template: title/description/canonical/OG price
  /// tags, hreflang alternates, and Product JSON-LD structured data.
  ///
  /// Swedish vs. Norwegian copy is picked off the deal's own currency (SEK
  /// vs. NOK) rather than a separate locale setting, since a product's
  /// currency already tells you which country's shoppers it's actually
  /// relevant to — there's no third audience to cover, every store feed in
  /// `scraper.py` is SEK or NOK.
  ///
  /// `canonicalUrl` resolves via the `/products/:id` route in `app.dart`
  /// (`ProductPage`), which also backs the `prerender_product_page` Cloud
  /// Function's crawlable static snapshot — see that function's docstring
  /// in `functions/main.py` for the dynamic-rendering pattern.
  void _syncProductMeta() {
    final deal = widget.deal;
    final storeName = storeDisplayName(deal.source);
    final isNorwegian = deal.currency.toUpperCase() == 'NOK';
    final canonicalUrl = 'https://prispuls.com/products/${deal.id}';
    final price = deal.currentPrice.toStringAsFixed(2);

    setDocumentTitle(
      '${deal.title} – ${deal.currentPrice.toStringAsFixed(0)} '
      '${deal.currency} | PrisPuls',
    );
    setMetaDescription(
      isNorwegian
          ? 'Sammenlign prisen på ${deal.title} hos $storeName og andre '
                'nettbutikker. PrisPuls sporer prishistorikken slik at du '
                'alltid vet om dette faktisk er et godt tilbud.'
          : 'Jämför priset på ${deal.title} hos $storeName och andra '
                'nätbutiker. PrisPuls spårar prishistoriken så du alltid vet '
                'om det här verkligen är ett bra pris.',
    );
    setCanonicalUrl(canonicalUrl);
    setHreflangAlternates({
      'sv-SE': canonicalUrl,
      'nb-NO': canonicalUrl,
      'x-default': canonicalUrl,
    });
    setOgPrice(amount: price, currency: deal.currency);
    setStructuredData(_productJsonLdId, {
      '@context': 'https://schema.org',
      '@type': 'Product',
      'name': deal.title,
      if (deal.imageUrl != null) 'image': [deal.imageUrl],
      'brand': {'@type': 'Brand', 'name': storeName},
      'offers': {
        '@type': 'Offer',
        'url': deal.url,
        'priceCurrency': deal.currency,
        'price': price,
        'availability': 'https://schema.org/InStock',
        'seller': {'@type': 'Organization', 'name': storeName},
      },
    });
  }

  Future<void> _openDealUrl() async {
    final deal = widget.deal;
    final uri = Uri.tryParse(deal.url);
    if (uri != null && await canLaunchUrl(uri)) {
      AnalyticsService().trackProductClick(
        itemId: deal.id,
        itemName: deal.title,
        itemBrand: storeDisplayName(deal.source),
        price: deal.currentPrice,
        currency: deal.currency,
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final targetCurrency = settings.displayCurrency;
    final converter = ref.watch(currencyConverterProvider.notifier);

    final displayPrice = converter.convert(
      deal.currentPrice,
      deal.currency,
      targetCurrency,
    );
    final formattedPrice = ref.watch(
      formattedPriceProvider(price: displayPrice, currency: targetCurrency),
    );
    final originalPrice = deal.originalPrice != null
        ? ref.watch(
            formattedPriceProvider(
              price: converter.convert(
                deal.originalPrice!,
                deal.currency,
                targetCurrency,
              ),
              currency: targetCurrency,
            ),
          )
        : null;

    final isFavorite = ref.watch(
      favoritesProvider.select(
        (favs) => favs.value?.contains(deal.id) ?? false,
      ),
    );

    return Scaffold(
      backgroundColor: GlassColors.background,
      // Using CustomScrollView to create a collapsing app bar effect
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            // Explicit rather than the default auto-back-button: reached
            // directly via `/products/:id` (a shared link, search result,
            // or browser refresh — see ProductPage), there's no back-stack
            // to pop, so Flutter wouldn't render a back button at all,
            // stranding that visitor with no way to reach the rest of the
            // app. Matches BrandLandingPage's identical fallback for
            // `/brands/:slug`.
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              tooltip: 'Back to PrisPuls',
              onPressed: () => Navigator.canPop(context)
                  ? Navigator.of(context).pop()
                  : context.go('/'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                storeDisplayName(deal.source),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  shadows: const [Shadow(blurRadius: 2, color: Colors.black54)],
                ),
              ),
              background: deal.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: deal.imageUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: GlassColors.surface,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 64,
                          color: GlassColors.textMuted,
                        ),
                      ),
                    )
                  : Container(color: GlassColors.surface),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? theme.colorScheme.primary : null,
                ),
                tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                onPressed: () => ref
                    .read(favoritesProvider.notifier)
                    .handleFavoriteTap(context, deal),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deal.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formattedPrice,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (deal.originalPrice != null &&
                          deal.originalPrice! > deal.currentPrice)
                        Text(
                          originalPrice!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const Spacer(),
                      if (deal.discountPercent != null &&
                          deal.discountPercent! > 0)
                        _DiscountBadge(discount: deal.discountPercent!),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // The core value prop, delivered on the page where a user
                  // actually evaluates a specific deal: the real tracked
                  // price history, not just today's sticker price.
                  PriceHistoryChart(deal: deal),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openDealUrl,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View on Retailer Site'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.discount});

  final double discount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-${discount.toStringAsFixed(0)}%',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
