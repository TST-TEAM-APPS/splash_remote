import 'package:splash_navigator/preferences_service.dart';

import 'feature_data.dart';

mixin ConfigMixin {
  final _configManager = ConfigManager.instance;
  final _storage = AppStorage.instance;

  void saveLastVisitedUrl(String url) => _storage.lastVisitedUrl = url;

  String loadTargetUrl() {
    final String cachedUrl = _storage.lastVisitedUrl;
    if (cachedUrl.isEmpty) {
      return targetData;
    }
    return cachedUrl;
  }

  String get targetData => _configManager.configData;
  bool get isEnabled => !_configManager.isDisabled;
}