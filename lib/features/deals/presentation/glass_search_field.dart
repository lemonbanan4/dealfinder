import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/glass_colors.dart';

/// The "Liquid Glass" search box, shared by the app-level top nav bar
/// (desktop/tablet) and the feed's own toolbar (mobile) — see
/// `searchControllerProvider` in feed_page.dart for why the controller and
/// focus node are passed in rather than created here.
class GlassSearchField extends StatelessWidget {
  const GlassSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.height,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: GlassColors.glowBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.search, color: Color(0xFF5A5A78)),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  cursorColor: const Color(0xFF00B4FF),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: l10n.searchHint,
                    hintStyle: const TextStyle(color: Color(0xFF5A5A78)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: onChanged,
                ),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF5A5A78)),
                  tooltip: l10n.clearSearch,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
