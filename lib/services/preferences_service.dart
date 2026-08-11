import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferences _prefs;
  PreferencesService(this._prefs);

  static const _themeModeKey = 'theme_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _weeklySummaryKey = 'weekly_summary_enabled';

  String? getThemeMode() => _prefs.getString(_themeModeKey);
  Future<void> setThemeMode(String mode) => _prefs.setString(_themeModeKey, mode);

  bool getNotificationsEnabled() => _prefs.getBool(_notificationsKey) ?? true;
  Future<void> setNotificationsEnabled(bool value) => _prefs.setBool(_notificationsKey, value);

  bool getWeeklySummaryEnabled() => _prefs.getBool(_weeklySummaryKey) ?? true;
  Future<void> setWeeklySummaryEnabled(bool value) => _prefs.setBool(_weeklySummaryKey, value);
}
