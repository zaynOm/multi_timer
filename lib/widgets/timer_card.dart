import 'package:flutter/material.dart';

import '../models/timer_data.dart';

class TimerCard extends StatelessWidget {
  final TimerData timer;
  final Function(String) onDelete;
  final Function(String) onToggle;
  final Function(String) onReset;

  const TimerCard({
    super.key,
    required this.timer,
    required this.onDelete,
    required this.onToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isCompleted = timer.remainingSeconds <= 0;
    final cardColor =
        isCompleted
            ? colorScheme.primaryContainer.withValues(alpha: 0.7)
            : timer.isRunning
            ? colorScheme.secondaryContainer.withValues(alpha: 0.7)
            : colorScheme.surfaceContainerHighest;

    return Card(
      elevation: 0,
      color: cardColor,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    timer.label,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () => onDelete(timer.id),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              timer.formattedTime,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isCompleted ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: timer.remainingSeconds > 0 ? () => onToggle(timer.id) : null,
                  icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(timer.isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => onReset(timer.id),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
