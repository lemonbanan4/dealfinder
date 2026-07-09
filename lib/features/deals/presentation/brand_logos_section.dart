import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/glass_colors.dart';
import '../../../widgets/glass_card.dart';
import '../providers/brands_provider.dart';

/// Icon CDNs like simpleicons.org (used by the seeded `brand_logos` rows)
/// always serve SVG, which Flutter's raster image codecs can't decode
/// reliably — `flutter_svg` is required for those. Other logo sources (a
/// CMS upload, a CDN-hosted PNG) still go through `CachedNetworkImage`.
bool _isSvgUrl(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  return path.endsWith('.svg') || url.contains('simpleicons.org');
}

/// "Utvalda Brands" — a row of tappable brand logos sourced from the
/// curated `brand_logos` table. Tapping a logo hands the brand name back to
/// [onBrandTap] so the caller can filter the feed (e.g. via the existing
/// search query).
///
/// Renders nothing when there are no brands or the fetch fails — this is a
/// supporting section, not critical content, so it shouldn't show an error
/// state on the homepage.
class BrandLogosSection extends ConsumerWidget {
  const BrandLogosSection({super.key, required this.onBrandTap});

  final ValueChanged<String> onBrandTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandsProvider);

    return brandsAsync.when(
      data: (brands) {
        if (brands.isEmpty) return const SizedBox.shrink();
        return _BrandSectionBody(brands: brands, onBrandTap: onBrandTap);
      },
      loading: () => const _BrandSectionSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _BrandSectionBody extends StatelessWidget {
  const _BrandSectionBody({required this.brands, required this.onBrandTap});

  final List<Brand> brands;
  final ValueChanged<String> onBrandTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: isDark
            ? GlassColors.background
            : theme.colorScheme.surfaceContainerLow,
        border: isDark
            ? const Border(
                top: BorderSide(color: GlassColors.glowBorder),
                bottom: BorderSide(color: GlassColors.glowBorder),
              )
            : null,
      ),
      child: Column(
        children: [
          Text(
            'Utvalda Brands',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
              color: isDark ? Colors.white : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ett litet urval av varumärken vi kan erbjuda dig till unika priser.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? Colors.white60
                  : theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 18,
            children: [
              for (final brand in brands)
                _BrandLogoTile(
                  brand: brand,
                  onTap: () => onBrandTap(brand.name),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single premium glass tile, matching the dim-white-logo-brightens-on-hover
/// treatment used by most "trusted by" brand strips: idle state is a muted
/// logo on a subtle glass card; on hover it lifts (scale), brightens to full
/// opacity, and the border/glow intensify.
class _BrandLogoTile extends StatefulWidget {
  const _BrandLogoTile({required this.brand, required this.onTap});

  final Brand brand;
  final VoidCallback onTap;

  @override
  State<_BrandLogoTile> createState() => _BrandLogoTileState();
}

class _BrandLogoTileState extends State<_BrandLogoTile> {
  // Tracked separately from GlassCard's own internal hover state — GlassCard
  // owns the border/shadow/lift treatment, this just drives the logo's
  // dim-to-bright opacity, which is specific to this "trusted by" tile and
  // not part of the shared glass-card hover spec.
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final logoUrl = widget.brand.logoUrl;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GlassCard(
        onTap: widget.onTap,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SizedBox(
          height: 44,
          width: 104,
          child: Tooltip(
            message: widget.brand.name,
            child: AnimatedOpacity(
              opacity: _hovering ? 1.0 : 0.62,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: logoUrl == null || logoUrl.isEmpty
                  ? _BrandTextBadge(name: widget.brand.name, dimmed: false)
                  : _BrandLogoImage(url: logoUrl, brand: widget.brand.name),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLogoImage extends StatelessWidget {
  const _BrandLogoImage({required this.url, required this.brand});

  final String url;
  final String brand;

  @override
  Widget build(BuildContext context) {
    if (_isSvgUrl(url)) {
      return SvgPicture.network(
        url,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const _LogoPlaceholder(),
        errorBuilder: (context, _, _) =>
            _BrandTextBadge(name: brand, dimmed: false),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, _) => const _LogoPlaceholder(),
      errorWidget: (context, _, _) =>
          _BrandTextBadge(name: brand, dimmed: false),
    );
  }
}

class _BrandTextBadge extends StatelessWidget {
  const _BrandTextBadge({required this.name, required this.dimmed});

  final String name;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: dimmed ? Colors.white60 : Colors.white,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38),
      ),
    );
  }
}

class _BrandSectionSkeleton extends StatelessWidget {
  const _BrandSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: isDark ? GlassColors.background : Colors.grey.shade50,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 18,
        runSpacing: 18,
        children: List.generate(
          6,
          (_) => Container(
            height: 64,
            width: 136,
            decoration: BoxDecoration(
              color: GlassColors.glassFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GlassColors.glowBorder),
            ),
          ),
        ),
      ),
    );
  }
}
