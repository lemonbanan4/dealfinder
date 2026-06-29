import 'package:flutter/material.dart';

class SegmentedSwitch<T> extends StatelessWidget {
  const SegmentedSwitch({
    required this.selected,
    required this.onSelect,
    required this.segments,
    super.key,
  });

  final T selected;
  final ValueChanged<T> onSelect;
  final Map<T, String> segments;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      segments: segments.entries.map((entry) {
        return ButtonSegment<T>(
          value: entry.key,
          label: Text(
            entry.value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
      selected: {selected},
      onSelectionChanged: (Set<T> selection) {
        if (selection.isNotEmpty) {
          onSelect(selection.first);
        }
      },
    );
  }
}
