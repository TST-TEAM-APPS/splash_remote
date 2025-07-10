import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:splash_navigator/feature_data.dart';
import 'package:splash_navigator/feature_mixin.dart';
import 'package:splash_navigator/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with ConfigMixin {
  // Получаем вшитую фиксированную дату из конфига
  DateTime get _startDay => ConfigManager.instance.startDate;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  String get link => targetData;

  int get days => ConfigManager.instance.waitingDays;

  bool get isEnabled {
    final now = DateTime.now();
    final difference = now.difference(_startDay).inDays;
    return difference >= days;
  }

  Future<void> _initializeAndNavigate() async {
    await AppStorage.instance.initialize();
    if (!isEnabled) {
      _navigateToMainScreen();
      return;
    }

    await _checkFeatureAvailability();
  }

  Future<void> _checkFeatureAvailability() async {
    try {
      final response = await http.get(Uri.parse(link), headers: {
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 15));
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
    //TODO check onboarding and navigate to main or onb
  }

  void _navigateToFeatureView() {
    if (mounted) {
     //TODO navigate to feature view
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Loading...',
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