import 'dart:async';

class TimerData {
  final String id;
  final String label;
  int remainingSeconds;
  final int totalSeconds;
  bool isRunning;
  Timer? timer;

  TimerData({
    required this.id,
    required this.label,
    required this.totalSeconds,
    this.isRunning = false,
  }) : remainingSeconds = totalSeconds;

  String get formattedTime {
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
