import 'package:flutter/material.dart';

class SettingRow extends StatelessWidget {
  const SettingRow({
    required this.icon,
    required this.label,
    required this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          // Flexible (not a bare child) — trailing (e.g. the 4-segment
          // currency SegmentedSwitch) previously had no flex sibling of its
          // own, so its full intrinsic width was a hard, non-negotiable
          // demand on the Row; on a narrow phone with SEK/NOK/EUR/USD all
          // shown, that's a real RenderFlex overflow risk. Flexible lets it
          // shrink instead of forcing a crash.
          Flexible(child: trailing),
        ],
      ),
    );
  }
}
