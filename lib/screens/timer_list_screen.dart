import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../providers/timers_provider.dart';
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

    // Default color options
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    // Selected color (default to first)
    Color selectedColor = colorOptions[0];
    bool isCustomColor = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setState) {
            // Show color picker dialog
            void showCustomColorPicker() {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                            isCustomColor = true;
                          });
                        },
                        pickerAreaHeightPercent: 0.8,
                        labelTypes: const [],
                        displayThumbColor: true,
                        portraitOnly: true,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Done'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }

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
                      : 'Timer ${context.read<TimerProvider>().timers.length + 1}';

              context.read<TimerProvider>().addTimer(
                label,
                hours,
                minutes,
                seconds,
                color: selectedColor,
              );
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
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              clipBehavior: Clip.none,
                              children: [
                                // Pre-defined colors
                                ...colorOptions.map((color) {
                                  final isSelected =
                                      !isCustomColor &&
                                      selectedColor.toARGB32() == color.toARGB32();

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() {
                                            selectedColor = color;
                                            isCustomColor = false;
                                          }),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border:
                                              isSelected
                                                  ? Border.all(
                                                    color: colorScheme.onSurface,
                                                    width: 3,
                                                  )
                                                  : null,
                                        ),
                                        child:
                                            isSelected
                                                ? Icon(
                                                  Icons.check,
                                                  color:
                                                      color.computeLuminance() > 0.5
                                                          ? Colors.black
                                                          : Colors.white,
                                                )
                                                : null,
                                      ),
                                    ),
                                  );
                                }),

                                // Custom color picker option
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: GestureDetector(
                                    onTap: showCustomColorPicker,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: const RadialGradient(
                                          colors: [Colors.red, Colors.green, Colors.blue],
                                          stops: [0.0, 0.5, 1.0],
                                        ),
                                        shape: BoxShape.circle,
                                        border:
                                            isCustomColor
                                                ? Border.all(color: colorScheme.onSurface, width: 3)
                                                : null,
                                      ),
                                      child: const Icon(Icons.color_lens, color: Colors.white),
                                    ),
                                  ),
                                ),

                                // Current custom color display
                                if (isCustomColor)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: selectedColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: colorScheme.onSurface, width: 1),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color:
                                            selectedColor.computeLuminance() > 0.5
                                                ? Colors.black
                                                : Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
        child: Consumer<TimerProvider>(
          builder: (context, timerService, child) {
            final timers = timerService.timers;

            if (timers.isEmpty) {
              return const EmptyState(
                icon: Icons.timer_outlined,
                title: 'No timers yet',
                message: 'Add a timer by tapping the + button below',
              );
            }

            final orientation = MediaQuery.of(context).orientation;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: orientation == Orientation.landscape ? 3 : 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: orientation == Orientation.landscape ? 1.2 : 0.8,
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
