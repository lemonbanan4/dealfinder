import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/glass_colors.dart';
import '../domain/product_category.dart';
import 'feed_page.dart';

/// The "Categories" hover/click dropdown — shared by the app-level top nav
/// bar (desktop, where it now lives in the slot Settings used to occupy)
/// and the feed's own mobile toolbar.
///
/// [onCategorySelected], if provided, fires *in addition* to updating
/// [feedFiltersProvider] — the top nav bar uses it to also switch to the
/// Feed tab, since picking a category only means something there.
class GlassCategoriesMenu extends ConsumerStatefulWidget {
  const GlassCategoriesMenu({super.key, this.onCategorySelected});

  final ValueChanged<String>? onCategorySelected;

  @override
  ConsumerState<GlassCategoriesMenu> createState() =>
      _GlassCategoriesMenuState();
}

class _GlassCategoriesMenuState extends ConsumerState<GlassCategoriesMenu> {
  final _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(feedFiltersProvider);
    final activeLabel = filters.category == 'All'
        ? 'Categories'
        : filters.category;

    return MenuAnchor(
      controller: _menuController,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          GlassColors.surface.withValues(alpha: 0.98),
        ),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        side: const WidgetStatePropertyAll(
          BorderSide(color: GlassColors.glowBorder),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: const WidgetStatePropertyAll(12),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      // A single scrollable child rather than one MenuItemButton per
      // category: with ~20 categories now (not just electronics), a flat
      // list of menu items would overflow the screen height on shorter
      // viewports, since MenuAnchor's panel doesn't scroll on its own.
      menuChildren: [
        SizedBox(
          width: 240,
          height: 420,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (final cat in dealCategories)
                MenuItemButton(
                  onPressed: () {
                    ref.read(feedFiltersProvider.notifier).updateCategory(cat);
                    widget.onCategorySelected?.call(cat);
                  },
                  leadingIcon: SizedBox(
                    width: 18,
                    child: filters.category == cat
                        ? const Icon(
                            Icons.check,
                            size: 18,
                            color: Color(0xFF00B4FF),
                          )
                        : null,
                  ),
                  child: Text(cat),
                ),
            ],
          ),
        ),
      ],
      builder: (context, controller, child) {
        return MouseRegion(
          onEnter: (_) {
            if (!controller.isOpen) controller.open();
          },
          child: OutlinedButton.icon(
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
            icon: const Icon(Icons.category_outlined, size: 18),
            label: Text(activeLabel, overflow: TextOverflow.ellipsis),
            style: OutlinedButton.styleFrom(
              foregroundColor: filters.category != 'All'
                  ? const Color(0xFF00B4FF)
                  : Colors.white70,
              side: BorderSide(
                color: filters.category != 'All'
                    ? GlassColors.glowBorderHover
                    : GlassColors.glowBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }
}
