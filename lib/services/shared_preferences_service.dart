import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _instance;

  static Future<void> initialize() async {
    _instance ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_instance == null) {
      throw Exception('SharedPreferencesService not initialized. Call initialize() first.');
    }
    return _instance!;
  }
}
