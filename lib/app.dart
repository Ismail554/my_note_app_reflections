import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_notes/core/config/router_config.dart';
import 'package:my_notes/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        title: 'Reflections',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouterConfig.router,
      ),
    );
  }
}
