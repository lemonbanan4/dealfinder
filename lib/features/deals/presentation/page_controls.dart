import 'package:flutter/material.dart';

import '../../../theme/glass_colors.dart';

/// Prev / numbered-page / Next controls for the deal grid, plus a
/// jump-to-page field. Shared by both the server-paginated default browse
/// mode and the client-paginated filtered/search/favorites mode (see
/// `pagedDealsProvider` / `filteredDealsPageProvider`) — both just need a
/// `(currentPage, totalPages, onPageChanged)` to drive this.
class PageControls extends StatelessWidget {
  const PageControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 8,
            children: [
              _NavButton(
                icon: Icons.chevron_left,
                tooltip: 'Previous page',
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              for (final page in _pagesToShow())
                if (page == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('…', style: TextStyle(color: Colors.white38)),
                  )
                else
                  _PageNumberButton(
                    page: page,
                    selected: page == currentPage,
                    onTap: () => onPageChanged(page),
                  ),
              _NavButton(
                icon: Icons.chevron_right,
                tooltip: 'Next page',
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
              if (currentPage < totalPages) ...[
                const SizedBox(width: 4),
                _TextNavButton(
                  label: 'Last',
                  onPressed: () => onPageChanged(totalPages),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _JumpToPageField(
            currentPage: currentPage,
            totalPages: totalPages,
            onSubmit: onPageChanged,
          ),
        ],
      ),
    );
  }

  /// First/last page, the current page ± 1, always shown; gaps in between
  /// collapse to a `null` ellipsis marker instead of listing every page.
  List<int?> _pagesToShow() {
    const edge = 1;
    const around = 1;
    final pages = <int>{
      for (var i = 1; i <= edge; i++) i,
      for (var i = totalPages - edge + 1; i <= totalPages; i++) i,
      for (var i = currentPage - around; i <= currentPage + around; i++) i,
    }.where((p) => p >= 1 && p <= totalPages).toList()..sort();

    final result = <int?>[];
    for (var i = 0; i < pages.length; i++) {
      if (i > 0 && pages[i] - pages[i - 1] > 1) result.add(null);
      result.add(pages[i]);
    }
    return result;
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: GlassColors.glassFill,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        iconSize: 20,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        icon: Icon(icon, color: enabled ? Colors.white : Colors.white24),
        onPressed: onPressed,
      ),
    );
  }
}

class _TextNavButton extends StatelessWidget {
  const _TextNavButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GlassColors.glassFill,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final int page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? GlassColors.priceAccent.withValues(alpha: 0.18)
          : GlassColors.glassFill,
      shape: const CircleBorder(
        side: BorderSide(color: GlassColors.glowBorder),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: selected ? null : onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              '$page',
              style: TextStyle(
                color: selected ? GlassColors.priceAccent : Colors.white70,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JumpToPageField extends StatefulWidget {
  const _JumpToPageField({
    required this.currentPage,
    required this.totalPages,
    required this.onSubmit,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onSubmit;

  @override
  State<_JumpToPageField> createState() => _JumpToPageFieldState();
}

class _JumpToPageFieldState extends State<_JumpToPageField> {
  late final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final page = int.tryParse(value);
    _controller.clear();
    if (page == null) return;
    widget.onSubmit(page.clamp(1, widget.totalPages));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Go to page (1-${widget.totalPages})',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          height: 34,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: GlassColors.glassFill,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: GlassColors.glowBorder),
              ),
            ),
            onSubmitted: _submit,
          ),
        ),
      ],
    );
  }
}
