class GreetingUtils {
  GreetingUtils._();

  /// Returns a time-based greeting string according to the user's local device time:
  /// - 05:00 – 11:59 → "Good morning"
  /// - 12:00 – 16:59 → "Good afternoon"
  /// - 17:00 – 21:59 → "Good evening"
  /// - 22:00 – 04:59 → "Good night"
  static String getGreeting([DateTime? time]) {
    final now = time ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  /// Returns the corresponding sun/moon emoji for the local time of day.
  static String getGreetingEmoji([DateTime? time]) {
    final now = time ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 17) {
      return '☀️';
    } else {
      return '🌙';
    }
  }

  /// Returns the formatted personalized greeting line: e.g. "Good morning, Heer ☀️"
  static String getPersonalizedGreeting(String? fullName, [DateTime? time]) {
    final greeting = getGreeting(time);
    final emoji = getGreetingEmoji(time);
    final name = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim().split(' ').first
        : 'there';
    return '$greeting, $name $emoji';
  }
}
