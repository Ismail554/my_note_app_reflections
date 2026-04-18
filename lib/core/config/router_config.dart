import 'package:go_router/go_router.dart';
import 'package:Reflections/core/utils/app_navigator.dart';
import 'package:Reflections/features/add_new/presentation/pages/add_note_page.dart';
import 'package:Reflections/features/auth/pages/login_page.dart';
import 'package:Reflections/features/auth/pages/register_page.dart';
import 'package:Reflections/features/home/pages/home_page.dart';
import 'package:Reflections/features/splash/presentation/pages/splash_page.dart';
import 'package:Reflections/routes/app_routes.dart';
import 'package:Reflections/shared/models/note_model.dart';

class AppRouterConfig {
  static final GoRouter router = GoRouter(
    navigatorKey: AppNavigator.navigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(path: AppRoutes.login, builder: (context, state) => LoginPage()),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.addNote,
        builder: (context, state) {
          final note = state.extra as NoteModel?;
          return AddNotePage(note: note);
        },
      ),
    ],
  );
}
