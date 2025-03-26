import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeWheelPicker extends StatelessWidget {
  final int hours;
  final int minutes;
  final int seconds;
  final Function(int) onHoursChanged;
  final Function(int) onMinutesChanged;
  final Function(int) onSecondsChanged;

  const TimeWheelPicker({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.onSecondsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hours picker
          _buildPickerColumn(
            context,
            'Hours',
            hours,
            24, // 0-23 hours
            onHoursChanged,
            colorScheme,
          ),

          // Minutes picker
          _buildPickerColumn(
            context,
            'Min',
            minutes,
            60, // 0-59 minutes
            onMinutesChanged,
            colorScheme,
          ),

          // Seconds picker
          _buildPickerColumn(
            context,
            'Sec',
            seconds,
            60, // 0-59 seconds
            onSecondsChanged,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildPickerColumn(
    BuildContext context,
    String label,
    int value,
    int maxItems,
    Function(int) onValueChanged,
    ColorScheme colorScheme,
  ) {
    final List<Widget> pickerItems = List.generate(
      maxItems,
      (index) => Center(
        child: Text(
          index.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 46,
              magnification: 1.2,
              squeeze: 1.1,
              diameterRatio: 1.8,
              looping: true,
              scrollController: FixedExtentScrollController(initialItem: value),
              onSelectedItemChanged: onValueChanged,
              children: pickerItems,
            ),
          ),
        ],
      ),
    );
  }
}
