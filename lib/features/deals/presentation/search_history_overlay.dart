import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/glass_dialog.dart';
import '../providers/search_history_provider.dart';

class SearchHistoryOverlay extends ConsumerWidget {
  const SearchHistoryOverlay({super.key, required this.onTap});
  final void Function(String) onTap;

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirm = await showGlassDialog<bool>(
      context: context,
      title: const Text('Clear Search History'),
      content: const Text(
        'Are you sure you want to clear all recent searches?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Clear'),
        ),
      ],
    );
    if (confirm == true && context.mounted) {
      ref.read(searchHistoryProvider.notifier).clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search history cleared.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(searchHistoryProvider);
    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) return const SizedBox.shrink();
        return Container(
          color: Theme.of(
            context,
          ).scaffoldBackgroundColor.withValues(alpha: 0.95),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8A8AA0),
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _confirmClear(context, ref),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Clear History'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      leading: Icon(
                        Icons.history,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(item),
                      onTap: () => onTap(item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
