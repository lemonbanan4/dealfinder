import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/glass_colors.dart';
import '../providers/deal_by_id_provider.dart';
import 'deal_details_page.dart';

/// The `/products/:id` route target — resolves a bare product id (from a
/// shared link, search result, or browser refresh; nothing already in
/// memory to look it up in) to a [Deal] via [dealByIdProvider], then hands
/// off to [DealDetailsPage] for the actual content/SEO-meta sync. Mirrors
/// `BrandLandingPage`'s id-resolution + not-found pattern for `/brands/:slug`.
class ProductPage extends ConsumerWidget {
  const ProductPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealAsync = ref.watch(dealByIdProvider(id));

    return dealAsync.when(
      data: (deal) => deal == null
          ? _ProductNotFoundView(id: id)
          : DealDetailsPage(deal: deal),
      loading: () => const Scaffold(
        backgroundColor: GlassColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _ProductNotFoundView(id: id),
    );
  }
}

class _ProductNotFoundView extends StatelessWidget {
  const _ProductNotFoundView({required this.id});

  final String id;

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
            const Text(
              'This deal is no longer available.',
              style: TextStyle(color: GlassColors.textHeading),
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
