import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/deals/domain/deal.dart';
import 'liquid_glass_background.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/alerts/providers/price_alerts_provider.dart'; // Import your provider path
import '../features/alerts/providers/alert_configs_provider.dart';
// Import the model we made!

// Design tokens
const _kPriceGreen = Color(0xFF00E676);
const _kAccentBlue = Color(0xFF00B4FF);
const _kDiscountRed = Color(0xFFFF4757);
const _kMuted = Color(0xFF5A5A78);
const _kMutedLight = Color(0xFF8A8AA0);

String _formatAmount(double price) {
  final rounded = price.round();
  final s = rounded.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

class DealCard extends StatelessWidget {
  const DealCard({
    super.key,
    required this.deal,
    required this.displayPrice,
    required this.currency,
    required this.onShare,
    this.trailingAction,
    this.onTap,
  });

  final Deal deal;
  final double displayPrice;
  final String currency;
  final Widget? trailingAction;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final discountPct = _computeDiscount();
    final vatPrice = _withVat(displayPrice, currency);
    final vatLabel = _vatLabel(currency);
    final host = Uri.tryParse(deal.url)?.host ?? '';

    return SizedBox(
      height: 130,
      child: LiquidGlassBackground(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: _kAccentBlue.withAlpha(20),
            highlightColor: _kAccentBlue.withAlpha(10),
            onTap: () async {
              final uri = Uri.tryParse(deal.url);
              if (uri != null && await canLaunchUrl(uri)) {
                // This safely opens the affiliate link in a new browser tab
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                debugPrint('Could not launch ${deal.url}');
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ImagePanel(imageUrl: deal.imageUrl, discountPct: discountPct),
                Expanded(
                  child: _DetailsPanel(
                    dealId: deal.id,
                    title: deal.title,
                    sourceName: deal.source,
                    merchantHost: host,
                    vatPrice: vatPrice,
                    currency: currency,
                    vatLabel: vatLabel,
                  ),
                ),
                if (trailingAction != null) trailingAction!,
                IconButton(icon: const Icon(Icons.share), onPressed: onShare),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int? _computeDiscount() {
    final orig = deal.originalPrice;
    if (orig == null || orig <= 0) return null;
    final effectiveCurrency = deal.currency;
    final double current;
    if (effectiveCurrency == currency && displayPrice > 0) {
      current = displayPrice;
    } else {
      return null;
    }
    if (orig <= current) return null;
    final pct = ((orig - current) / orig * 100).round();
    return pct > 0 ? pct : null;
  }

  // void _copyLink(BuildContext context) {
  //   Clipboard.setData(ClipboardData(text: deal.url));
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Link copied to clipboard'),
  //       behavior: SnackBarBehavior.floating,
  //       duration: Duration(seconds: 2),
  //     ),
  //   );
  // }

  static double _withVat(double price, String currency) {
    // Awin feeds for SE/NO already include VAT. do not multiply !
    if (currency == 'SEK' || currency == 'NOK') return price;
    return price;
  }

  static String _vatLabel(String currency) => switch (currency) {
    'NOK' => 'inkl. MVA',
    'SEK' => 'inkl. moms',
    _ => '',
  };
}

// ─── Image panel (left 110 px) ────────────────────────────────────────────────

class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.imageUrl, this.discountPct});
  final String? imageUrl;
  final int? discountPct;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Deep dark-blue base — matches the glass fill tone.
          const ColoredBox(color: Color(0xFF060919)),
          // Faint electric-blue refractive glow behind the product image.
          Positioned(
            top: 15,
            left: 5,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kAccentBlue.withAlpha(14),
                boxShadow: [
                  BoxShadow(
                    color: _kAccentBlue.withAlpha(55),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          _buildImage(),
          if (discountPct != null)
            Positioned(
              top: 8,
              left: 8,
              child: _DiscountBadge(pct: discountPct!),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final url = imageUrl;
    if (url == null || url.isEmpty) return const _ImageFallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1B2A), Color(0xFF23243A)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: Color(0xFF3A3A58),
          size: 32,
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.pct});
  final int pct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _kDiscountRed,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: _kDiscountRed.withAlpha(100),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '-$pct%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: -0.2,
          height: 1,
        ),
      ),
    );
  }
}

// ─── Details panel (right, flexible) ─────────────────────────────────────────

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({
    required this.dealId,
    required this.title,
    required this.sourceName,
    required this.merchantHost,
    required this.vatPrice,
    required this.currency,
    required this.vatLabel,
  });

  final String dealId;
  final String title;
  final String sourceName;
  final String merchantHost;
  final double vatPrice;
  final String currency;
  final String vatLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _MerchantRow(
                  sourceName: sourceName,
                  merchantHost: merchantHost,
                ),
              ],
            ),
          ),
          _PriceTrend(dealId: dealId),
          const SizedBox(height: 4),
          _PriceRow(vatPrice: vatPrice, currency: currency, vatLabel: vatLabel),
        ],
      ),
    );
  }
}

class _MerchantRow extends StatelessWidget {
  const _MerchantRow({required this.sourceName, required this.merchantHost});
  final String sourceName;
  final String merchantHost;

  // Helper method
  String _formatSourceName(String source) {
    final lower = source.toLowerCase();
    if (lower.contains('all_no') || lower.contains('all no'))
      return 'Norway Deals 🇳🇴';
    if (lower.contains('all_se') || lower.contains('all se'))
      return 'Sweden Deals 🇸🇪';
    return source; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _favicon(),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            _formatSourceName(sourceName),
            style: const TextStyle(
              color: _kMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _favicon() {
    if (merchantHost.isEmpty) {
      return const Icon(Icons.store_outlined, size: 14, color: _kMuted);
    }
    final url = 'https://www.google.com/s2/favicons?sz=16&domain=$merchantHost';
    return SizedBox(
      width: 14,
      height: 14,
      child: Image.network(
        url,
        width: 14,
        height: 14,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.store_outlined, size: 14, color: _kMuted),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.vatPrice,
    required this.currency,
    required this.vatLabel,
  });
  final double vatPrice;
  final String currency;
  final String vatLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatAmount(vatPrice),
              style: const TextStyle(
                color: _kPriceGreen,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              currency,
              style: const TextStyle(
                color: _kPriceGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (vatLabel.isNotEmpty)
          Text(
            vatLabel,
            style: const TextStyle(color: _kMuted, fontSize: 10, height: 1.4),
          ),
      ],
    );
  }
}

// ─── 30-day price trend sparkline ─────────────────────────────────────────────

class _PriceTrend extends StatelessWidget {
  const _PriceTrend({required this.dealId});
  final String dealId;

  @override
  Widget build(BuildContext context) {
    // Deterministic pseudo-random trend seeded from deal ID — placeholder for real history.
    final seed = dealId.codeUnits.fold(0, (a, b) => a ^ b);
    final rng = math.Random(seed);
    var v = 0.75 + rng.nextDouble() * 0.25;
    final data = <double>[v];
    for (var i = 1; i < 30; i++) {
      v = (v + (rng.nextDouble() - 0.52) * 0.15).clamp(0.05, 1.0);
      data.add(v);
    }

    return SizedBox(
      height: 20,
      child: CustomPaint(
        painter: _SparklinePainter(data: data),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.data});
  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final min = data.reduce(math.min);
    final max = data.reduce(math.max);
    final range = (max - min).clamp(0.001, double.infinity);

    List<Offset> points(double verticalPadding) {
      return [
        for (var i = 0; i < data.length; i++)
          Offset(
            i / (data.length - 1) * size.width,
            size.height -
                verticalPadding -
                ((data[i] - min) / range) * (size.height - verticalPadding * 2),
          ),
      ];
    }

    final pts = points(1.5);

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = _kMutedLight.withAlpha(160)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final fillPath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kMutedLight.withAlpha(30), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => false;
}
