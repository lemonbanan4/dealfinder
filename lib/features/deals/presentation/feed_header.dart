import 'package:flutter/material.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ListenableBuilder(
        listenable: searchController,
        builder: (context, _) {
          return SearchBar(
            controller: searchController,
            focusNode: searchFocusNode,
            hintText: 'Search products or brands...',
            leading: const Icon(Icons.search, color: Color(0xFF5A5A78)),
            trailing: [
              if (searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF5A5A78)),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                )
            ],
            onChanged: onSearchChanged,
          );
        },
      ),
    );
  }
}
