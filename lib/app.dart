import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final String theme = context.watch<SettingsProvider>().themeMode.toString();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.contains('dark') ? Brightness.light : Brightness.dark,
      ),
    );

    return ScreenUtil(
      options: ScreenUtilOptions(
        designSize: const Size(376, 872),
        fontFactorByWidth: 2.0,
        fontFactorByHeight: 1.0,
        flipSizeWhenLandscape: true,
      ),
      child: Consumer<SettingsProvider>(
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
