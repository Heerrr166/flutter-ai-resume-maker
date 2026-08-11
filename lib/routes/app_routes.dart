class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';
  static const String resume = '/resume';
  static const String resumeList = '/resume/list';
  static const String resumeEditor = '/resume/:resumeId/edit';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String adminUsers = '/admin/users';

  static const String splashName = 'splash';
  static const String onboardingName = 'onboarding';
  static const String loginName = 'login';
  static const String signupName = 'signup';
  static const String forgotPasswordName = 'forgot-password';
  static const String resetPasswordName = 'reset-password';
  static const String dashboardName = 'dashboard';
  static const String resumeName = 'resume';
  static const String resumeListName = 'resume-list';
  static const String resumeEditorName = 'resume-editor';
  static const String profileName = 'profile';
  static const String settingsName = 'settings';
  static const String adminUsersName = 'admin-users';

  static String resumeEditorPath(String resumeId) => '/resume/$resumeId/edit';

  static const publicRoutes = <String>{
    splash,
    onboarding,
    login,
    signup,
    forgotPassword,
    resetPassword,
  };

  static const authEntryRoutes = <String>{
    splash,
    onboarding,
    login,
    signup,
  };
}
