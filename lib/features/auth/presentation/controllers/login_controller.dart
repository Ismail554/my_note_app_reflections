import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_notes/core/services/auth_service.dart';
import 'package:my_notes/core/utils/app_navigator.dart';

class LoginController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Firebase Auth sign in
      await AuthService.to.signInWithEmailAndPassword(email, password);
      AppNavigator.goToHome();

      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage.value = 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        errorMessage.value = 'The email address is not valid.';
      } else {
        errorMessage.value = e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      errorMessage.value = 'Login failed. Please check your credentials.';
    } finally {
      isLoading.value = false;
    }
  }










  void navigateToRegister() {
    AppNavigator.goToRegister();
  }
}
