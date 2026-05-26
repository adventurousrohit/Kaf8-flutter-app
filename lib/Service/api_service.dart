import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://8.231.67.123:5000/api";

  /// ✅ Register API
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    String role = "client",
    String? fullName,
    String? location,
    String? vehicleType,
    String? vehiclePhoto,
    bool? availability,
    String? address,
    String? avatar,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register");
    final Map<String, dynamic> body = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "phone": phone,
      "role": role,
    };

    if (fullName != null) body["fullName"] = fullName;
    if (location != null) body["location"] = location;
    if (vehicleType != null) body["vehicleType"] = vehicleType;
    if (vehiclePhoto != null) body["vehiclePhoto"] = vehiclePhoto;
    if (availability != null) body["availability"] = availability;
    if (address != null) body["address"] = address;
    if (avatar != null) body["avatar"] = avatar;

    debugPrint("🚀 API REQUEST [REGISTER]: $url");
    debugPrint("📦 BODY: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("✅ API RESPONSE [REGISTER]: ${response.statusCode}");
      debugPrint("📄 DATA: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // Normalize success field if missing but status is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        data['success'] = true;
      }

      return data;
    } catch (e) {
      debugPrint("❌ API ERROR [REGISTER]: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Login API
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");
    final body = {
      "identifier": email,
      "password": password,
    };

    debugPrint("🚀 API REQUEST [LOGIN]: $url");
    debugPrint("📦 BODY: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("✅ API RESPONSE [LOGIN]: ${response.statusCode}");
      debugPrint("📄 DATA: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        data['success'] = true; // Normalize for UI logic

        final prefs = await SharedPreferences.getInstance();
        
        final accessToken = data['token'] ?? data['accessToken'] ?? (data['data'] != null ? data['data']['accessToken'] : null);
        final refreshToken = data['refreshToken'] ?? (data['data'] != null ? data['data']['refreshToken'] : null);
        
        final user = data['user'] ?? data['data']?['user'];
        final role = user != null ? user['role'] : (data['role'] ?? data['data']?['role']);

        debugPrint("💾 Saving Session: Token=${accessToken != null}, Role=$role");

        if (accessToken != null) await prefs.setString('accessToken', accessToken.toString());
        if (refreshToken != null) await prefs.setString('refreshToken', refreshToken.toString());
        if (role != null) await prefs.setString('userRole', role.toString());
      }

      return data;
    } catch (e) {
      debugPrint("❌ API ERROR [LOGIN]: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Refresh Token API
  static Future<bool> refreshTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) return false;

    final url = Uri.parse("$baseUrl/auth/refresh-token");
    final body = {"refreshToken": refreshToken};

    debugPrint("🚀 API REQUEST [REFRESH TOKEN]: $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("✅ API RESPONSE [REFRESH TOKEN]: ${response.statusCode}");
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (data['data'] != null) {
          final newAccessToken = data['data']['accessToken'];
          final newRefreshToken = data['data']['refreshToken'];

          if (newAccessToken != null) await prefs.setString('accessToken', newAccessToken);
          if (newRefreshToken != null) await prefs.setString('refreshToken', newRefreshToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("❌ API ERROR [REFRESH TOKEN]: $e");
      return false;
    }
  }

  /// ✅ Get Access Token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  /// ✅ Get User Role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  /// ✅ Is Logged In
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// ✅ Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userRole');
  }

  /// ✅ Authenticated Helper
  static Future<http.Response> authenticatedRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    var token = await getAccessToken();
    headers ??= {};
    headers["Authorization"] = "Bearer $token";
    headers["Content-Type"] = "application/json";

    http.Response response;
    if (method == 'POST') {
      response = await http.post(url, headers: headers, body: body);
    } else {
      response = await http.get(url, headers: headers);
    }

    if (response.statusCode == 401) {
      final success = await refreshTokens();
      if (success) {
        token = await getAccessToken();
        headers["Authorization"] = "Bearer $token";
        if (method == 'POST') {
          return await http.post(url, headers: headers, body: body);
        } else {
          return await http.get(url, headers: headers);
        }
      } else {
        await logout();
        Get.offAllNamed('/login');
      }
    }
    return response;
  }
}
