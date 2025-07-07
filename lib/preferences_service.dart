import 'package:shared_preferences/shared_preferences.dart';
import 'feature_data.dart';

class AppStorage {
  AppStorage._internal();
  static final AppStorage instance = AppStorage._internal();

  SharedPreferences? _preferences;

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  String get lastVisitedUrl {
    final value = _preferences?.getString(AppStrings.lastUrlKey);
    return value ?? '';
  }

  set lastVisitedUrl(String value) {
    _preferences?.setString(AppStrings.lastUrlKey, value);
  }
}