import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/seo/document_meta.dart';
import '../../../theme/glass_colors.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/glass_container.dart';
import '../domain/brand_landing.dart';
import '../presentation/deal_slivers.dart';
import '../providers/brand_landing_provider.dart';
import '../providers/favorites_provider.dart';

/// A dedicated, crawlable "Best Deals on {brand} in {region}" page — see
/// `BrandLanding`/`brandLandings` for the definitive list. Reachable at
/// `/brands/:slug` (see the GoRouter config in app.dart) and, for search
/// crawlers specifically, served as a separate prerendered static HTML
/// snapshot by the `prerender_brand_page` Cloud Function (Firebase Hosting
/// rewrites `/brands/**` there) — this Flutter page is what real visitors
/// see after that shell loads, or when navigating here from within the app.
class BrandLandingPage extends ConsumerStatefulWidget {
  const BrandLandingPage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<BrandLandingPage> createState() => _BrandLandingPageState();
}

class _BrandLandingPageState extends ConsumerState<BrandLandingPage> {
  @override
  void initState() {
    super.initState();
    _syncDocumentMeta();
  }

  @override
  void didUpdateWidget(covariant BrandLandingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) _syncDocumentMeta();
  }

  void _syncDocumentMeta() {
    final landing = brandLandingsBySlug[widget.slug];
    if (landing == null) return;
    setDocumentTitle('${landing.title} | PrisPuls');
    setMetaDescription(
      'Compare live prices on ${landing.brandName} products in '
      '${landing.regionName}. PrisPuls tracks prices across retailers so '
      'you always see the best deal first.',
    );
    setCanonicalUrl('https://prispuls.com/brands/${landing.slug}');
  }

  @override
  Widget build(BuildContext context) {
    final landing = brandLandingsBySlug[widget.slug];

    if (landing == null) {
      return _BrandNotFoundView(slug: widget.slug);
    }

    final dealsAsync = ref.watch(brandLandingDealsProvider(landing.storeFeed));

    return Scaffold(
      backgroundColor: GlassColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/'),
          tooltip: 'Back to PrisPuls',
        ),
        title: const AppLogo(iconSize: 24, fontSize: 18),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      landing.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: GlassColors.textHeading,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    dealsAsync.when(
                      data: (deals) => Text(
                        deals.isEmpty
                            ? 'No live ${landing.brandName} deals right now — check back soon.'
                            : 'Tracking ${deals.length} ${landing.brandName} '
                                  'products in ${landing.regionName}, updated '
                                  'continuously as prices change.',
                        style: const TextStyle(color: GlassColors.textMuted),
                      ),
                      loading: () => const Text(
                        'Loading live prices…',
                        style: TextStyle(color: GlassColors.textMuted),
                      ),
                      error: (_, _) => const Text(
                        'Could not load deals right now.',
                        style: TextStyle(color: GlassColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: dealsAsync.when(
              data: (deals) => DealsSliver(
                deals: deals,
                isEmpty: deals.isEmpty,
                onFavoriteTap: (deal) => ref
                    .read(favoritesProvider.notifier)
                    .handleFavoriteTap(context, deal),
              ),
              loading: () => DealsSliver(
                deals: const [],
                isLoading: true,
                onFavoriteTap: (_) {},
              ),
              error: (error, _) => DealsSliver(
                deals: const [],
                onFavoriteTap: (_) {},
                error: error,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _BrandNotFoundView extends StatelessWidget {
  const _BrandNotFoundView({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 48,
              color: GlassColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No page for "$slug"',
              style: const TextStyle(color: GlassColors.textHeading),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to PrisPuls'),
            ),
          ],
        ),
      ),
    );
  }
}
