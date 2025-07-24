import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// Register a new user
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String country,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'country': country,
        'password': password,
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Login a user
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // You can save token here using SharedPreferences if needed
      return true;
    } else {
      return false;
    }
  }
}
