import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  l10n.noDealsFound,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.checkBackLater),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.refreshNow),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    required this.query,
    required this.onClear,
  });
  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_off_outlined,
                      size: 64,
                      color: Color(
                        0xFF5A5A78,
                      ), // Kept for specific design choice
                    ),
                    const SizedBox(height: 16),
                    Text(
                      query.isNotEmpty
                          ? l10n.noResultsFor(query)
                          : l10n.noDealsMatchFilters,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tryCheckingTypos,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8A8AA0),
                      ), // Kept for specific design choice
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.clear),
                      label: Text(l10n.clearFilters),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.error.withAlpha(30),
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
