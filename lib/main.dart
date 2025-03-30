import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'services/timer_service.dart';
import 'services/timer_storage_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  await themeService.initialize();

  final timerStorage = TimerStorageService();
  await timerStorage.initialize();

  await NotificationService().initialize();

  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;

  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerService()),
        ChangeNotifierProvider.value(value: themeService),
      ],
      child: Consumer<ThemeService>(
        builder:
            (context, themeService, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Multi Timer',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeService.themeMode,
              home: const HomeScreen(),
            ),
      ),
    );
  }
}
