import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final int current;
  final int total;
  final bool showLabel;

  const ProgressBarWidget({
    super.key,
    required this.current,
    required this.total,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? current / total : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            '$current / $total',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
