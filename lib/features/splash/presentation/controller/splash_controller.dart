import 'package:get/get.dart';
import 'package:my_notes/core/services/auth_service.dart';
import 'package:my_notes/core/utils/app_navigator.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if user is already logged in
    if (AuthService.to.currentUser != null) {
      AppNavigator.goToHome();
    } else {
      AppNavigator.goToLogin();
    }
  }
}


// Launch
//   └── SplashPage (shown always, 2s)
//         ├── User logged in  → HomePage
//         └── Not logged in   → LoginPage
//                                   ├── Login success → HomePage
//                                   └── Register link → RegisterPage
//                                                           └── Register success → HomePage
