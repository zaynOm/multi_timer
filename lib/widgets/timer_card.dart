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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: timer.remainingSeconds / timer.totalSeconds,
                    strokeWidth: 7,
                    color: isCompleted ? colorScheme.primary : colorScheme.secondary,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                Text(
                  timer.formattedTime,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              timer.label,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: timer.remainingSeconds > 0 ? () => onToggle(timer.id) : null,
                  icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 16),
                IconButton(onPressed: () => onReset(timer.id), icon: const Icon(Icons.refresh)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
