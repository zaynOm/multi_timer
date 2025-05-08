import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:multi_timer/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'providers/ad_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/timers_provider.dart';
import 'services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());
  tz.initializeTimeZones();

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
      ChangeNotifierProvider.value(value: getIt<SettingsProvider>()),
      ChangeNotifierProvider.value(value: getIt<TimerProvider>()),
      ChangeNotifierProvider(create: (_) => AdProvider()),
    ],
    child: const AppRoot(),
  );

  runApp(app);
}
