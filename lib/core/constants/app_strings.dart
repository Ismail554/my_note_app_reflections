class AppStrings {
  // ─── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'Reflections';
  static const String appTagline = 'The quiet curator for your thoughts.';

  // ─── Splash ───────────────────────────────────────────────────────────────
  static const String splashTagline = appTagline;

  // ─── Login ────────────────────────────────────────────────────────────────
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Return to your reflections.';
  static const String loginButton = 'Login';
  static const String loginEmailHint = 'Enter your email';
  static const String loginPasswordHint = 'Enter your password';
  static const String loginForgotPassword = 'Forgot Password ?';
  static const String loginNoAccount = "New to Reflections? ";
  static const String loginCreateAccount = 'Create an account';

  // ─── Register ─────────────────────────────────────────────────────────────
  static const String registerTitle = 'Begin.';
  static const String registerQuote =
      '"The quietest moments hold the loudest truths."';
  static const String registerNameHint = 'Full name';
  static const String registerEmailHint = 'Email address';
  static const String registerPasswordHint = 'Create a password';
  static const String registerButton = 'Create Account';
  static const String registerHaveAccount = 'Already have a space? ';
  static const String registerReturnLogin = 'Return to Login';

  // ─── Home ─────────────────────────────────────────────────────────────────
  static const String homeTitle = 'Thoughts';
  static const String homeSubtitle =
      'A curated collection of your recent observations, ideas, and fleeting moments.';
  static const String homeEmpty =
      'No notes yet.\nStart writing your first thought.';
  static const String homeEmptyAction = 'Write something';

  // ─── Add Note ─────────────────────────────────────────────────────────────
  static const String addNoteTitle = 'New Note';
  static const String addNoteSave = 'Save';
  static const String addNoteTitleHint = 'Give it a title...';
  static const String addNoteBodyHint = 'Start writing...';
  static const String addNoteCategory = 'Reflections';

  // ─── Error Messages ───────────────────────────────────────────────────────
  static const String errorEmpty = 'This field cannot be empty';
  static const String errorInvalidEmail = 'Please enter a valid email address';
  static const String errorPasswordShort =
      'Password must be at least 6 characters';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetworkTitle = 'No note title provided';
}
