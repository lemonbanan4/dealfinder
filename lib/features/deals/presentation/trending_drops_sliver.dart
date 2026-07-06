import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/deal_card.dart';
import '../providers/trending_drops_provider.dart';
import 'horizontal_deal_sliver.dart';

/// The "Biggest Price Drops" shelf — the 3 products whose price fell the
/// most over the last 24h. Hidden entirely whenever there's nothing to show
/// (see [HorizontalDealSliver]'s empty-state handling), since a quiet 24h
/// window is a normal, not-broken state.
class TrendingDropsSliver extends ConsumerWidget {
  const TrendingDropsSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HorizontalDealSliver(
      dealsProvider: trendingDropsProvider,
      header: const _TrendingDropsHeader(),
      view: DealCardView.grid,
    );
  }
}

class _TrendingDropsHeader extends StatelessWidget {
  const _TrendingDropsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 4, 0),
      child: Row(
        children: [
          const Icon(Icons.trending_down, color: Color(0xFF00E6A8), size: 18),
          const SizedBox(width: 6),
          const Text(
            'Biggest Price Drops',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00E6A8).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Last 24h',
              style: TextStyle(
                color: Color(0xFF00E6A8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
