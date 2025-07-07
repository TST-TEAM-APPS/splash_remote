import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:splash_navigator/feature_data.dart';
import 'package:splash_navigator/main.dart';
import 'package:splash_navigator/onboarding_screen.dart';
import 'package:splash_navigator/preferences_service.dart';
import 'feature_mixin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with ConfigMixin {
  DateTime? _startDay;
  static const String _startDayKey = 'start_day';

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  String get link => targetData;

  int get days => ConfigManager.instance.waitingDays;

  bool get isEnabled {
    if (_startDay == null) return false;

    final now = DateTime.now();
    final difference = now.difference(_startDay!).inDays;
    return difference >= days;
  }

  Future<void> _initializeAndNavigate() async {
    await AppStorage.instance.initialize();

    await _loadStartDay();

    if (_startDay == null) {
      await _saveStartDay();
    }

    if (!isEnabled) {
      _navigateToMainScreen();
      return;
    }

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
        Uri.parse(link),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _navigateToFeatureView();
      } else {

        _navigateToMainScreen();
      }
    } catch (e) {
      _navigateToMainScreen();
    }
  }

  void _navigateToMainScreen() async {
    final prefs = await SharedPreferences.getInstance(); //TODO переделать под вашу конфигурацию
    final onBoardingIsComplete =
        prefs.getBool('first_run') ?? true;
    if (onBoardingIsComplete) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => MainScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => OnboardingScreen(),
        ),
      );
    }
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main'); //TODO ваша реализация
    }
  }

  void _navigateToFeatureView() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/feature'); //TODO ваша реализация
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
            Icon(
              Icons.flutter_dash,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
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