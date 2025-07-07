import 'preferences_service.dart';

// Класс для управления конфигурацией
class ConfigManager {
  ConfigManager._internal();
  static final ConfigManager instance = ConfigManager._internal();

  // Вшитая ссылка для проверки
  String get configData => 'http://45.32.235.77/FLzF8H';

  // Количество дней ожидания для сплеша
  int get waitingDays => 0;

  // Флаг для отключения функции (по умолчанию включена)
  bool get isDisabled => false;
}

// Константы для ключей SharedPreferences
class AppStrings {
  static const String lastUrlKey = 'last_visited_url';
}