import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: EdgeInsets.all(context.r(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: context.r(110),
                  height: context.r(110),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween<double>(
                      begin: (timer.remainingSeconds + 1) / timer.totalSeconds,
                      end: timer.remainingSeconds / timer.totalSeconds,
                    ),
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: context.r(5),
                        strokeCap: StrokeCap.round,
                        color: isCompleted ? colorScheme.primary : timer.color,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      );
                    },
                  ),
                ),
                Text(
                  timer.formattedTime,
                  textScaler: TextScaler.noScaling,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: timer.formattedTime.length > 5 ? context.sp(22) : context.sp(30),
                    color: isCompleted ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.r(12)),
            Text(
              timer.label,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: context.sp(18.0),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.r(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: timer.remainingSeconds > 0 ? () => onToggle(timer.id) : null,
                  icon: Icon(timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () => onReset(timer.id),
                  icon: Icon(Icons.refresh_rounded),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () => onDelete(timer.id),
                  icon: Icon(Icons.delete_rounded, color: colorScheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
