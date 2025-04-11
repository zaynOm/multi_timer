import 'dart:async';

import 'package:flutter/material.dart';

class TimerData {
  final String id;
  final String label;
  final int totalSeconds;
  int remainingSeconds;
  bool isRunning;
  Timer? timer;
  final Color color; // Added color property

  TimerData({
    required this.id,
    required this.label,
    required this.totalSeconds,
    this.remainingSeconds = 0,
    this.isRunning = false,
    this.color = Colors.blue, // Default color
  }) {
    remainingSeconds = totalSeconds;
  }

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
      'color': color.toARGB32(), // Save color as an integer value
    };
  }

  // Create a TimerData from a JSON Map
  factory TimerData.fromJson(Map<String, dynamic> json) {
    final timer = TimerData(
      id: json['id'],
      label: json['label'],
      totalSeconds: json['totalSeconds'],
      isRunning: false, // Always load timers as paused
      color: Color(json['color']), // Load color from integer value
    );
    // Handle remaining seconds separately to keep any progress
    timer.remainingSeconds = json['remainingSeconds'];
    return timer;
  }
}
