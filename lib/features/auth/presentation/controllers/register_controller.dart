import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_notes/core/services/auth_service.dart';
import 'package:my_notes/core/services/user_service.dart';
import 'package:my_notes/core/utils/app_navigator.dart';

class RegisterController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value =  ' Register error..';

      // 1. Create user in Firebase Auth
      final userCredential = await AuthService.to
          .registerWithEmailAndPassword(email, password);

      final user = userCredential.user;
      if (user != null) {
        // 2. Update display name in Auth
        await AuthService.to.updateDisplayName(name);

        // 3. Create user profile in Firestore
        await UserService.to.createUserProfile(
          uid: user.uid,
          name: name,
          email: email,
        );

        // 4. Navigate to home
        AppNavigator.goToHome();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorMessage.value = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage.value = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage.value = 'The email address is not valid.';
      } else {
        errorMessage.value = e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      errorMessage.value = 'Registration failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToLogin() {
    AppNavigator.goBack();
  }
}
