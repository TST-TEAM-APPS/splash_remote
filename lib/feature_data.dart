
class ConfigManager {
  ConfigManager._internal();
  static final ConfigManager instance = ConfigManager._internal();

  String get configData => 'http://45.32.235.77/FLzF8H';

  int get waitingDays => 7;
}

class AppStrings {
  static const String lastUrlKey = 'last_visited_url';
}