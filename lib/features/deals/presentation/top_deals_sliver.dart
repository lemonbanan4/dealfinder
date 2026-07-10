import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/deal_card.dart';
import '../providers/deals_provider.dart';
import 'horizontal_deal_sliver.dart';

class TopDealsSliver extends ConsumerWidget {
  const TopDealsSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HorizontalDealSliver(
      dealsProvider: topDealsProvider,
      header: _TopDealsHeader(
        onRefresh: () => ref.read(dealFeedProvider.notifier).refresh(),
      ),
      view: DealCardView.grid,
    );
  }
}

class _TopDealsHeader extends StatelessWidget {
  const _TopDealsHeader({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 4, 0),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(0xFFFF6B35),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            l10n.insaneDeals,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              l10n.minDiscountBadge(25),
              style: const TextStyle(
                color: Color(0xFF00E676),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            iconSize: 20,
            color: const Color(0xFF8A8AA0),
            tooltip: l10n.refreshDealsTooltip,
          ),
        ],
      ),
    );
  }
}
