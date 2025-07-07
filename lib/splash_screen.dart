import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:splash_navigator/feature_data.dart';
import 'package:splash_navigator/preferences_service.dart';
import 'feature_mixin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with ConfigMixin {
  // Приватное поле для хранения стартового дня
  DateTime? _startDay;

  // Ключ для SharedPreferences
  static const String _startDayKey = 'start_day';

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  // Getter для ссылки через ConfigMixin
  String get link => targetData;

  // Getter для количества дней через ConfigMixin
  int get days => ConfigManager.instance.waitingDays;

  // Getter для проверки активности функции (комбинируем логику времени и isEnabled из ConfigMixin)
  bool get isTimeEnabled {
    if (_startDay == null) return false;

    final now = DateTime.now();
    final difference = now.difference(_startDay!).inDays;
    return difference >= days;
  }

  // Общий getter для проверки доступности функции
  bool get isFeatureEnabled => isTimeEnabled && isEnabled;

  Future<void> _initializeAndNavigate() async {
    // Инициализируем AppStorage если еще не инициализирован
    await AppStorage.instance.initialize();

    await _loadStartDay();

    // Если пользователь первый раз открывает приложение
    if (_startDay == null) {
      await _saveStartDay();
    }

    // Проверяем, прошло ли достаточно дней И включена ли функция в конфиге
    if (!isFeatureEnabled) {
      // Переходим на MainScreen если не прошло достаточно дней или функция отключена
      _navigateToMainScreen();
      return;
    }

    // Если прошло достаточно дней и функция включена, делаем HTTP-запрос
    await _checkFeatureAvailability();
  }

  Future<void> _loadStartDay() async {
    final prefs = await SharedPreferences.getInstance();
    final startDayString = prefs.getString(_startDayKey);

    if (startDayString != null) {
      _startDay = DateTime.parse(startDayString);
    }
  }

  Future<void> _saveStartDay() async {
    final prefs = await SharedPreferences.getInstance();
    _startDay = DateTime.now();
    await prefs.setString(_startDayKey, _startDay!.toIso8601String());
  }

  Future<void> _checkFeatureAvailability() async {
    try {
      final response = await http.get(
        Uri.parse(link), // Используем ссылку из ConfigMixin
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Сохраняем URL для использования в FeatureView
        saveLastVisitedUrl(link);
        print('LINK: $link');
        _navigateToFeatureView();
      } else {
        _navigateToMainScreen();
      }
    } catch (e) {
      // При ошибке сети или тайм-ауте также переходим на MainScreen
      _navigateToMainScreen();
    }
  }

  void _navigateToMainScreen() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  void _navigateToFeatureView() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/feature');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Логотип или изображение
            Icon(
              Icons.flutter_dash,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            // Индикатор загрузки
            CircularProgressIndicator(
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              'Загрузка...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}