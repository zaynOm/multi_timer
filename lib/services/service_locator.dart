import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';
import 'shared_preferences_service.dart';
import 'theme_service.dart';
import 'timer_service.dart';
import 'timer_storage_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    // Initialize SharedPreferencesService first
    await SharedPreferencesService.initialize();

    // Register SharedPreferences as singleton
    getIt.registerSingleton<SharedPreferences>(SharedPreferencesService.instance);

    // Register services
    getIt.registerSingleton<ThemeService>(ThemeService());
    getIt.registerSingleton<TimerStorageService>(TimerStorageService());
    getIt.registerSingleton<NotificationService>(NotificationService());
    getIt.registerSingleton<TimerService>(TimerService());

    // Initialize services
    await getIt<ThemeService>().initialize();
    await getIt<TimerStorageService>().initialize();
    await getIt<NotificationService>().initialize();
    await getIt<TimerProvider>().initialize();
  }
}
