import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeService = context.watch<ThemeService>();

    String getThemeText(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return 'System';
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
      }
    }

    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.primary),
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6, color: colorScheme.primary),
            title: const Text('Theme'),
            subtitle: Text(getThemeText(themeService.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => SimpleDialog(
                      title: const Text('Select Theme'),
                      children:
                          ThemeMode.values
                              .map(
                                (mode) => RadioListTile<ThemeMode>(
                                  title: Text(getThemeText(mode)),
                                  value: mode,
                                  groupValue: themeService.themeMode,
                                  onChanged: (value) {
                                    if (value != null) {
                                      themeService.setThemeMode(value);
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                              )
                              .toList(),
                    ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.primary),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.primary),
            ),
          ),
          ListTile(
            leading: Icon(Icons.policy, color: colorScheme.primary),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            onTap: () async {
              await launchUrl(Uri.parse("https://visual-timer-plus.netlify.app"));
            },
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
