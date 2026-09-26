class AppConstants {
  AppConstants._();

  /// Production cloud API endpoint on Render
  static const String apiBase = "https://jeevandisha.onrender.com/api";
  static const String apiBaseUrl = apiBase;

  static const Duration timeout = Duration(seconds: 15);
  static const Duration apiTimeout = timeout;

  static const String appName = 'JeevanDisha';
  static const String appTagline = 'Find your direction, one step at a time';

  static const Duration splashDelay = Duration(milliseconds: 1800);

  static const List<String> feelingLabels = [
    'Calm',
    'Hopeful',
    'Tired',
    'Anxious',
    'Focused',
    'Overwhelmed',
  ];
}
