import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_timer/config.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeService = context.watch<SettingsProvider>();
    // bool isSoundEnabled = themeService.isSoundEnabled;
    // bool isVibrationEnabled = themeService.isVibrationEnabled;

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
          SizedBox(height: context.h(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontSize: context.sp(Theme.of(context).textTheme.titleSmall?.fontSize ?? 14.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6, color: colorScheme.primary, size: context.r(24)),
            title: Text('Theme', style: TextStyle(fontSize: context.sp(16))),
            subtitle: Text(
              getThemeText(themeService.themeMode),
              style: TextStyle(fontSize: context.sp(14)),
            ),
            trailing: Icon(Icons.chevron_right, size: context.r(24)),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => SimpleDialog(
                      title: Text('Select Theme', style: TextStyle(fontSize: context.sp(18))),
                      children:
                          ThemeMode.values
                              .map(
                                (mode) => RadioListTile<ThemeMode>(
                                  title: Text(
                                    getThemeText(mode),
                                    style: TextStyle(fontSize: context.sp(16)),
                                  ),
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

          // const Divider(),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: Text(
          //     'Notifications',
          //     style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.primary),
          //   ),
          // ),
          // SwitchListTile(
          //   title: const Text('Sound'),
          //   subtitle: const Text('Play sound when timer completes'),
          //   secondary: Icon(Icons.volume_up, color: colorScheme.primary),
          //   value: isSoundEnabled,
          //   onChanged: (value) {
          //     themeService.toggleSound(value);
          //   },
          // ),
          // SwitchListTile(
          //   title: const Text('Vibration'),
          //   subtitle: const Text('Vibrate when timer completes'),
          //   secondary: Icon(Icons.vibration, color: colorScheme.primary),
          //   value: isVibrationEnabled,
          //   onChanged: (value) {
          //     themeService.toggleVibration(value);
          //   },
          // ),
          const Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontSize: context.sp(Theme.of(context).textTheme.titleSmall?.fontSize ?? 14.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.policy, color: colorScheme.primary, size: context.r(24)),
            title: Text('Privacy Policy', style: TextStyle(fontSize: context.sp(16))),
            subtitle: Text('Read our privacy policy', style: TextStyle(fontSize: context.sp(14))),
            onTap: () async {
              await launchUrl(Uri.parse("https://visual-timer-plus.netlify.app"));
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: colorScheme.primary, size: context.r(24)),
            title: Text('App version', style: TextStyle(fontSize: context.sp(16))),
            subtitle: Text(appVersion, style: TextStyle(fontSize: context.sp(14))),
          ),
        ],
      ),
    );
  }
}
