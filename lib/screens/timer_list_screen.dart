import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/timer_service.dart';
import '../widgets/time_wheel_picker.dart';
import '../widgets/timer_card.dart';

class TimerListScreen extends StatefulWidget {
  const TimerListScreen({super.key});

  @override
  State<TimerListScreen> createState() => _TimerListScreenState();
}

class _TimerListScreenState extends State<TimerListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TimerService>().initialize();
  }

  void _showAddTimerDialog() {
    final labelController = TextEditingController();
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setState) {
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
                      onHoursChanged: (value) => setState(() => hours = value),
                      onMinutesChanged: (value) => setState(() => minutes = value),
                      onSecondsChanged: (value) => setState(() => seconds = value),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final label =
                              labelController.text.trim().isNotEmpty
                                  ? labelController.text.trim()
                                  : 'Timer ${context.read<TimerService>().timers.length + 1}';
                          context.read<TimerService>().addTimer(label, hours, minutes, seconds);
                          Navigator.pop(context);
                        },
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Consumer<TimerService>(
          builder: (context, timerService, child) {
            final timers = timerService.timers;

            if (timers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 64,
                      color: colorScheme.primary.withValues(alpha: .5),
                    ),
                    const SizedBox(height: 16),
                    Text('No timers yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Add a timer by tapping the + button below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: timers.length,
              itemBuilder: (context, index) {
                final timer = timers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TimerCard(
                    timer: timer,
                    onDelete: (id) => timerService.deleteTimer(id),
                    onToggle: (id) => timerService.toggleTimer(id),
                    onReset: (id) => timerService.resetTimer(id),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimerDialog,
        tooltip: 'Add Timer',
        child: const Icon(Icons.add),
      ),
    );
  }
}
