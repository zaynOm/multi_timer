import 'package:flutter/material.dart';
import 'package:multi_timer/widgets/empty_state.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.bookmark_outline,
          title: 'No presets yet',
          message: 'Save your favorite timer configurations here',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement preset creation
        },
        tooltip: 'Add Preset',
        child: const Icon(Icons.add),
      ),
    );
  }
}
