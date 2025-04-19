import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';
import '../providers/timers_provider.dart';
import 'notification_service.dart';
import 'shared_preferences_service.dart';
import 'timer_storage_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    // Initialize SharedPreferencesService first
    await SharedPreferencesService.initialize();

    // Register SharedPreferences as singleton
    getIt.registerSingleton<SharedPreferencesAsync>(SharedPreferencesService.instance);

    // Register services
    getIt.registerSingleton<SettingsProvider>(SettingsProvider());
    getIt.registerSingleton<TimerStorageService>(TimerStorageService());
    getIt.registerSingleton<NotificationService>(NotificationService(getIt<SettingsProvider>()));
    getIt.registerSingleton<TimerProvider>(
      TimerProvider(getIt<TimerStorageService>(), getIt<NotificationService>()),
    );

    // Initialize services
    await getIt<SettingsProvider>().initialize();
    await getIt<TimerStorageService>().initialize();
    await getIt<NotificationService>().initialize();
    await getIt<TimerProvider>().initialize();
  }
}
