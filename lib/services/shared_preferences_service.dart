import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferencesAsync? _instance;

  static Future<void> initialize() async {
    _instance ??= SharedPreferencesAsync();
  }

  static SharedPreferencesAsync get instance {
    if (_instance == null) {
      throw Exception('SharedPreferencesService not initialized. Call initialize() first.');
    }
    return _instance!;
  }
}
