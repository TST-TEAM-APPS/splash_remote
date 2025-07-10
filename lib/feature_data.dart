import 'preferences_service.dart';

// Класс для управления конфигурацией
class ConfigManager {
  ConfigManager._internal();
  static final ConfigManager instance = ConfigManager._internal();

  // Вшитая ссылка для проверки
  String get configData => 'link';

  // Количество дней ожидания для сплеша
  int get waitingDays => 7;

  // Вшитая фиксированная дата старта (настраивается вручную)
  DateTime get startDate => DateTime(2025, 1, 1); // TODO: Настроить нужную дату
}

// Константы для ключей SharedPreferences
class AppStrings {
  static const String lastUrlKey = 'last_visited_url';
}