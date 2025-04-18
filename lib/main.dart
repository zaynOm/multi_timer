import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_timer/firebase_options.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/service_locator.dart';
import 'services/theme_service.dart';
import 'services/timer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Enable Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Initialize all services
  await ServiceLocator.setup();

  final app = MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: getIt<ThemeService>()),
      ChangeNotifierProvider.value(value: getIt<TimerService>()),
    ],
    child: const AppRoot(),
  );

  runApp(app);
}
