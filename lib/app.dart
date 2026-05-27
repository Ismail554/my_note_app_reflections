import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/config/router_config.dart';
import 'package:Reflections/core/theme/app_theme.dart';
import 'package:Reflections/core/localization/app_translations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp.router(
        title: 'Reflections',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routeInformationParser: AppRouterConfig.router.routeInformationParser,
        routerDelegate: AppRouterConfig.router.routerDelegate,
        routeInformationProvider: AppRouterConfig.router.routeInformationProvider,
        translations: AppTranslations(),
        locale: Get.deviceLocale ?? const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
      ),
    );
  }
}
