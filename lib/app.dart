import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/config/router_config.dart';
import 'package:Reflections/core/theme/app_theme.dart';
import 'package:Reflections/core/localization/app_translations.dart';
import 'package:Reflections/core/providers/settings_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final languageProvider = context.watch<LanguageProvider>();
        final settingsProvider = context.watch<SettingsProvider>();

        return MaterialApp.router(
          title: 'Reflections',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settingsProvider.themeMode,
          routeInformationParser: AppRouterConfig.router.routeInformationParser,
          routerDelegate: AppRouterConfig.router.routerDelegate,
          routeInformationProvider: AppRouterConfig.router.routeInformationProvider,
          locale: languageProvider.locale,
        );
      },
    );
  }
}
