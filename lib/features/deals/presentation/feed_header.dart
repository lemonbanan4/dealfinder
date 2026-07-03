import 'package:flutter/material.dart';

import '../../../widgets/glass_container.dart';

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
          return GlassContainer(
            borderRadius: 28,
            blurSigma: 18,
            hoverBlurSigma: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.search, color: Color(0xFF5A5A78)),
                ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: const Color(0xFF00B4FF),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Search products or brands...',
                      hintStyle: TextStyle(color: Color(0xFF5A5A78)),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF5A5A78)),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
