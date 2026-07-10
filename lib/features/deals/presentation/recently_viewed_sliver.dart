import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/deal_card.dart';
import '../../../widgets/glass_dialog.dart';
import '../providers/recently_viewed_provider.dart';
import 'horizontal_deal_sliver.dart';

class RecentlyViewedSliver extends ConsumerWidget {
  const RecentlyViewedSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HorizontalDealSliver(
      dealsProvider: recentDealsProvider,
      header: const _RecentlyViewedHeader(),
      view: DealCardView.list, // Use a ListView for recents
    );
  }
}

class _RecentlyViewedHeader extends ConsumerWidget {
  const _RecentlyViewedHeader();

  Future<void> _clearRecents(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: Text(l10n.clearHistoryTitle),
      content: Text(l10n.clearHistoryConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.clear),
        ),
      ],
    );
    if (confirm == true) {
      ref.read(recentlyViewedProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.history, color: Color(0xFF8A8AA0), size: 18),
          const SizedBox(width: 6),
          Text(
            l10n.recentlyViewed,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _clearRecents(context, ref),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8A8AA0),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              l10n.clearAll,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
