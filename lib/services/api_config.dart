import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    String url = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';
    if (kIsWeb) {
      final uri = Uri.parse(url);
      // Hanya ganti host ke localhost jika bukan HTTPS (development lokal).
      // URL produksi (HTTPS) dibiarkan apa adanya.
      if (uri.scheme != 'https') {
        url = uri.replace(host: 'localhost').toString();
      }
    }
    // Pastikan tidak ada trailing slash
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
