import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/glass_colors.dart';
import 'feed_page.dart';

String _sortLabel(AppLocalizations l10n, ProductSort sort) => switch (sort) {
  ProductSort.none => l10n.sortBestDeals,
  ProductSort.priceAsc => l10n.sortPriceLowHigh,
  ProductSort.priceDesc => l10n.sortPriceHighLow,
  ProductSort.newest => l10n.sortNewest,
};

/// A single, minimal "Sort by" control above the deals grid — the one piece
/// of toolbar UI CLAUDE.md's otherwise-deliberately-bare feed toolbar makes
/// room for, since it's consistently the #1 control users expect on an
/// affiliate deal site.
class SortDropdown extends ConsumerWidget {
  const SortDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(feedFiltersProvider.select((f) => f.sort));
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<ProductSort>(
      initialValue: sort,
      tooltip: l10n.sortTooltip,
      offset: const Offset(0, 44),
      color: GlassColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: GlassColors.glowBorder),
      ),
      onSelected: (value) =>
          ref.read(feedFiltersProvider.notifier).updateSort(value),
      itemBuilder: (context) => ProductSort.values
          .map(
            (value) => PopupMenuItem(
              value: value,
              child: Text(
                _sortLabel(l10n, value),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: value == sort ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          )
          .toList(),
      child: Material(
        color: GlassColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sort, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                l10n.sortButtonLabel(_sortLabel(l10n, sort)),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
