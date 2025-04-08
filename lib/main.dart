import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/service_locator.dart';
import 'services/theme_service.dart';
import 'services/timer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
