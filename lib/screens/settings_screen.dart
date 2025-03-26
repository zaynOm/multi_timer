import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Appearance',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: colorScheme.primary),
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6, color: colorScheme.primary),
            title: const Text('Theme'),
            subtitle: const Text('Light, dark, or system default'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement theme selection
            },
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Notifications',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: colorScheme.primary),
            ),
          ),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Play sound when timer completes'),
            secondary: Icon(Icons.volume_up, color: colorScheme.primary),
            value: true,
            onChanged: (value) {
              // TODO: Implement sound toggle
            },
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate when timer completes'),
            secondary: Icon(Icons.vibration, color: colorScheme.primary),
            value: true,
            onChanged: (value) {
              // TODO: Implement vibration toggle
            },
          ),

          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'About',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: colorScheme.primary),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info, color: colorScheme.primary),
            title: const Text('App version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
