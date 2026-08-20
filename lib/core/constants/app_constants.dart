import 'app_host.dart';

class AppConstants {
  AppConstants._();

  static const String appTitle = 'AI Resume Maker';
  static const String appTagline = 'Build a resume that gets noticed.';
  static const String appDescription =
      'Build a professional resume with AI-powered writing help and local resume intelligence, then export it in seconds.';
  static const Duration splashDelay = Duration(seconds: 2);

  static String get apiBaseUrl => 'http://${currentApiHost()}:5000/api';
}
