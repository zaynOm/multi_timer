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

  // Convert TimerData to a JSON-serializable Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'remainingSeconds': remainingSeconds,
      'totalSeconds': totalSeconds,
      'isRunning': false, // Always save timers as paused
    };
  }

  // Create a TimerData from a JSON Map
  factory TimerData.fromJson(Map<String, dynamic> json) {
    final timer = TimerData(
      id: json['id'],
      label: json['label'],
      totalSeconds: json['totalSeconds'],
      isRunning: false, // Always load timers as paused
    );
    // Handle remaining seconds separately to keep any progress
    timer.remainingSeconds = json['remainingSeconds'];
    return timer;
  }
}
