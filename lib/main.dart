import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/timer_service.dart';
import 'services/timer_storage_service.dart';
import 'theme.dart';

void main() async {
  // Ensure Flutter is initialized before doing anything with plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await TimerStorageService.initializePrefs();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Multi Timer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
