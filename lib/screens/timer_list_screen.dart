import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/timer_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/time_wheel_picker.dart';
import '../widgets/timer_card.dart';

class TimerListScreen extends StatelessWidget {
  const TimerListScreen({super.key});

  void _showAddTimerDialog(BuildContext context) {
    final labelController = TextEditingController();
    int hours = 0;
    int minutes = 0;
    int seconds = 5;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setState) {
            // Validate timer duration
            bool isTimeSet() {
              return hours > 0 || minutes > 0 || seconds > 0;
            }

            void addTimer() {
              if (!isTimeSet()) {
                setState(() {
                  errorMessage = 'Please set a duration for the timer';
                });
                return;
              }

              final label =
                  labelController.text.trim().isNotEmpty
                      ? labelController.text.trim()
                      : 'Timer ${context.read<TimerService>().timers.length + 1}';

              context.read<TimerService>().addTimer(label, hours, minutes, seconds);
              Navigator.pop(context);
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add New Timer',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: labelController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Timer Label',
                        hintText: 'Enter a name for this timer',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: .3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TimeWheelPicker(
                      hours: hours,
                      minutes: minutes,
                      seconds: seconds,
                      onHoursChanged:
                          (value) => setState(() {
                            hours = value;
                            if (errorMessage != null) errorMessage = null;
                          }),
                      onMinutesChanged:
                          (value) => setState(() {
                            minutes = value;
                            if (errorMessage != null) errorMessage = null;
                          }),
                      onSecondsChanged:
                          (value) => setState(() {
                            seconds = value;
                            if (errorMessage != null) errorMessage = null;
                          }),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: colorScheme.error, fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: addTimer,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Add Timer'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TimerService>(
          builder: (context, timerService, child) {
            final timers = timerService.timers;

            if (timers.isEmpty) {
              return const EmptyState(
                icon: Icons.timer_outlined,
                title: 'No timers yet',
                message: 'Add a timer by tapping the + button below',
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: timers.length,
              itemBuilder: (context, index) {
                final timer = timers[index];
                return TimerCard(
                  timer: timer,
                  onDelete: (id) => timerService.deleteTimer(id),
                  onToggle: (id) => timerService.toggleTimer(id),
                  onReset: (id) => timerService.resetTimer(id),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTimerDialog(context),
        tooltip: 'Add Timer',
        child: const Icon(Icons.add),
      ),
    );
  }
}
