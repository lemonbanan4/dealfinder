import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/glass_colors.dart';
import '../domain/product_category.dart';
import 'feed_page.dart';

/// Presentation-only icon per category — purely decorative, so it lives here
/// rather than in `product_category.dart` (which is the actual title-keyword
/// classification logic, not UI).
const Map<String, IconData> _categoryIcons = {
  'Smartphones': Icons.smartphone,
  'Tablets': Icons.tablet_mac,
  'Wearables': Icons.watch,
  'Laptops/PC': Icons.laptop_mac,
  'Monitors': Icons.desktop_windows,
  'TVs': Icons.tv,
  'Audio': Icons.headphones,
  'Gaming Accessories': Icons.sports_esports,
  'Accessories': Icons.cable,
  'Home Electronics': Icons.kitchen,
  'Fashion & Clothing': Icons.checkroom,
  'Beauty & Health': Icons.spa,
  'Home & Garden': Icons.yard,
  'Sports & Outdoors': Icons.sports_soccer,
  'Toys & Kids': Icons.toys,
  'Groceries & Food': Icons.local_grocery_store,
  'Automotive': Icons.directions_car,
  'Books & Media': Icons.menu_book,
  'Pets': Icons.pets,
  'Travel & Luggage': Icons.luggage,
};

/// Groups [dealCategories] (excluding 'All', which gets its own link) into
/// the two real sections the catalog is actually split across today — see
/// `product_category.dart`'s own note that it's electronics-heavy with a
/// broader general-marketplace taxonomy layered on top. Mirrors that same
/// split rather than inventing a deeper taxonomy the data can't back up.
const List<(String, IconData, List<String>)> _categoryGroups = [
  (
    'Electronics & Tech',
    Icons.bolt,
    [
      'Smartphones',
      'Tablets',
      'Wearables',
      'Laptops/PC',
      'Monitors',
      'TVs',
      'Audio',
      'Gaming Accessories',
      'Accessories',
      'Home Electronics',
    ],
  ),
  (
    'Lifestyle & Everyday',
    Icons.home_outlined,
    [
      'Fashion & Clothing',
      'Beauty & Health',
      'Home & Garden',
      'Sports & Outdoors',
      'Toys & Kids',
      'Groceries & Food',
      'Automotive',
      'Books & Media',
      'Pets',
      'Travel & Luggage',
    ],
  ),
];

/// The "Categories" hover/click dropdown — shared by the app-level top nav
/// bar (desktop, where it now lives in the slot Settings used to occupy)
/// and the feed's own mobile toolbar.
///
/// Renders as a wide, grouped mega-menu on desktop (two columns — see
/// [_categoryGroups] — each item with an icon, closer to how Amazon/
/// PriceRunner-style sites organize a large category set) and falls back to
/// the previous compact single-column scrolling list on narrow/mobile
/// viewports, where a multi-column panel would overflow the screen width.
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

  void _select(String category) {
    ref.read(feedFiltersProvider.notifier).updateCategory(category);
    widget.onCategorySelected?.call(category);
    _menuController.close();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(feedFiltersProvider);
    final activeLabel = filters.category == 'All'
        ? 'Categories'
        : filters.category;
    final isWide = MediaQuery.sizeOf(context).width >= 720;

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
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevation: const WidgetStatePropertyAll(12),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
      ),
      menuChildren: [
        isWide
            ? _MegaMenu(activeCategory: filters.category, onSelect: _select)
            : _CompactMenu(activeCategory: filters.category, onSelect: _select),
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

/// Desktop panel: an "All Categories" link spanning the top, then the two
/// [_categoryGroups] side by side, each its own labeled column of icon +
/// text rows.
class _MegaMenu extends StatelessWidget {
  const _MegaMenu({required this.activeCategory, required this.onSelect});

  final String activeCategory;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CategoryRow(
            label: 'All Categories',
            icon: Icons.apps,
            selected: activeCategory == 'All',
            onTap: () => onSelect('All'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 9, color: GlassColors.glowBorder),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _categoryGroups.length; i++) ...[
                  if (i > 0)
                    const VerticalDivider(
                      width: 1,
                      color: GlassColors.glowBorder,
                    ),
                  Expanded(
                    child: _CategoryColumn(
                      group: _categoryGroups[i],
                      activeCategory: activeCategory,
                      onSelect: onSelect,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryColumn extends StatelessWidget {
  const _CategoryColumn({
    required this.group,
    required this.activeCategory,
    required this.onSelect,
  });

  final (String, IconData, List<String>) group;
  final String activeCategory;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final (title, icon, categories) = group;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
            child: Row(
              children: [
                Icon(icon, size: 15, color: GlassColors.textMuted),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: GlassColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          for (final category in categories)
            _CategoryRow(
              label: category,
              icon: _categoryIcons[category],
              selected: activeCategory == category,
              onTap: () => onSelect(category),
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: onTap,
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          selected ? const Color(0xFF00B4FF) : GlassColors.textBody,
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      leadingIcon: Icon(
        icon ?? Icons.circle,
        size: icon != null ? 17 : 5,
        color: selected ? const Color(0xFF00B4FF) : GlassColors.textMuted,
      ),
      trailingIcon: selected
          ? const Icon(Icons.check, size: 16, color: Color(0xFF00B4FF))
          : null,
      child: Text(
        label,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// Mobile/narrow-screen fallback: the original compact single-column
/// scrolling list (a multi-column mega-menu would overflow this width),
/// now with the same category icons as the desktop menu for consistency.
class _CompactMenu extends StatelessWidget {
  const _CompactMenu({required this.activeCategory, required this.onSelect});

  final String activeCategory;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 420,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          for (final cat in dealCategories)
            _CategoryRow(
              label: cat,
              icon: cat == 'All' ? Icons.apps : _categoryIcons[cat],
              selected: activeCategory == cat,
              onTap: () => onSelect(cat),
            ),
        ],
      ),
    );
  }
}
