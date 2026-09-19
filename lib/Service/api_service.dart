import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _apiHost = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://8.231.67.123:5000",
  );
  static const String baseUrl = "$_apiHost/api";

  static Map<String, dynamic> _normalizeResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (decoded is Map<String, dynamic>) {
      final hasSuccess = decoded.containsKey('success');
      if (!hasSuccess) {
        decoded['success'] =
            response.statusCode >= 200 && response.statusCode < 300;
      }
      return decoded;
    }

    return {
      "success": response.statusCode >= 200 && response.statusCode < 300,
      "data": decoded,
      "message": response.statusCode >= 200 && response.statusCode < 300
          ? "OK"
          : "Request failed with status ${response.statusCode}",
    };
  }

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
    final body = {"identifier": email, "password": password};

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

        final accessToken =
            data['accessToken'] ??
            data['token'] ??
            (data['data'] != null ? data['data']['accessToken'] : null);
        final refreshToken =
            data['refreshToken'] ??
            (data['data'] != null ? data['data']['refreshToken'] : null);

        final user = data['user'] ?? data['data']?['user'];
        final role = user != null
            ? user['role']
            : (data['role'] ?? data['data']?['role']);
        final userId = user != null ? user['id'] : null;

        debugPrint(
          "💾 Saving Session: Token=${accessToken != null}, Role=$role, UserId=$userId",
        );

        if (accessToken != null)
          await prefs.setString('accessToken', accessToken.toString());
        if (refreshToken != null)
          await prefs.setString('refreshToken', refreshToken.toString());
        if (role != null) await prefs.setString('userRole', role.toString());
        if (userId != null) await prefs.setString('userId', userId.toString());
      }

      return data;
    } catch (e) {
      debugPrint("❌ API ERROR [LOGIN]: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Forgot Password API — sends reset code to email
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final url = Uri.parse("$baseUrl/auth/forgot-password");
    debugPrint("🚀 API REQUEST [FORGOT PASSWORD]: $url");
    debugPrint("📦 BODY: {\"email\": \"$email\"}");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      debugPrint("✅ API RESPONSE [FORGOT PASSWORD]: ${response.statusCode}");
      debugPrint("📄 DATA: ${response.body}");
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) data['success'] = true;
      return data;
    } catch (e) {
      debugPrint("❌ API ERROR [FORGOT PASSWORD]: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Verify Reset Code API
  static Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse("$baseUrl/auth/verify-reset-code");
    debugPrint("🚀 API REQUEST [VERIFY RESET CODE]: $url");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "code": code}),
      );
      debugPrint("✅ API RESPONSE [VERIFY RESET CODE]: ${response.statusCode}");
      debugPrint("📄 DATA: ${response.body}");
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) data['success'] = true;
      return data;
    } catch (e) {
      debugPrint("❌ API ERROR [VERIFY RESET CODE]: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Reset Password API
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/auth/reset-password");
    debugPrint("🚀 API REQUEST [RESET PASSWORD]: $url");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "code": code,
          "newPassword": newPassword,
        }),
      );
      debugPrint("✅ API RESPONSE [RESET PASSWORD]: ${response.statusCode}");
      debugPrint("📄 DATA: ${response.body}");
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) data['success'] = true;
      return data;
    } catch (e) {
      debugPrint("❌ API ERROR [RESET PASSWORD]: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await authenticatedRequest(
        'PATCH',
        Uri.parse("$baseUrl/auth/change-password"),
        body: jsonEncode({
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        }),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final token = await getAccessToken();
      final url = Uri.parse("$baseUrl/users/avatar");
      debugPrint("🚀 API REQUEST [PATCH MULTIPART]: $url");
      final request = http.MultipartRequest(
        'PATCH',
        url,
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          filePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      debugPrint("✅ API RESPONSE [PATCH MULTIPART] [$url]: ${response.statusCode}");
      debugPrint("📄 DATA: ${response.body}");
      return _normalizeResponse(response);
    } catch (e) {
      debugPrint("❌ API ERROR [UPLOAD AVATAR]: $e");
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
      debugPrint("📄 DATA: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (data['data'] != null) {
          final newAccessToken = data['data']['accessToken'];
          final newRefreshToken = data['data']['refreshToken'];

          if (newAccessToken != null)
            await prefs.setString('accessToken', newAccessToken);
          if (newRefreshToken != null)
            await prefs.setString('refreshToken', newRefreshToken);
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

  /// ✅ Get User ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// ✅ Get My Orders (role-filtered)
  static Future<Map<String, dynamic>> getMyOrders({String? status}) async {
    var url = "$baseUrl/order/my-orders";
    if (status != null) url += "?status=$status";
    debugPrint("📡 ApiService: Calling getMyOrders with status=$status");
    try {
      final response = await authenticatedRequest('GET', Uri.parse(url));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint("❌ ApiService ERROR [getMyOrders]: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Get pending orders available to pick up (transporter)
  static Future<Map<String, dynamic>> getPendingAvailableOrders() async {
    debugPrint("📡 ApiService: Calling getPendingAvailableOrders");
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/order/pending-available"),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint("❌ ApiService ERROR [getPendingAvailableOrders]: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Create Order
  static Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        Uri.parse("$baseUrl/order/create"),
        body: jsonEncode(orderData),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201) data['success'] = true;
      return data;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Accept Order (transporter)
  static Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    try {
      final response = await authenticatedRequest(
        'PATCH',
        Uri.parse("$baseUrl/order/$orderId/accept"),
        body: jsonEncode({}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Update Order Status
  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status, {
    String? cancelReason,
  }) async {
    try {
      final body = <String, dynamic>{"status": status};
      if (cancelReason != null) body["cancelReason"] = cancelReason;
      final response = await authenticatedRequest(
        'PATCH',
        Uri.parse("$baseUrl/order/$orderId/status"),
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Profile APIs
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/users/profile"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await authenticatedRequest(
        'PATCH',
        Uri.parse("$baseUrl/users/profile"),
        body: jsonEncode(payload),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateTransporterProfile(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await authenticatedRequest(
        'PATCH',
        Uri.parse("$baseUrl/users/transporter-profile"),
        body: jsonEncode(payload),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Notification Settings APIs
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/notification-settings"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateNotificationSettings(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await authenticatedRequest(
        'PUT',
        Uri.parse("$baseUrl/notification-settings"),
        body: jsonEncode(payload),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Feedback APIs
  static Future<Map<String, dynamic>> submitFeedback(
    Map<String, dynamic> payload,
  ) async {
    try {
      final userId = await getUserId();
      final response = await authenticatedRequest(
        'POST',
        Uri.parse("$baseUrl/feedback/submit"),
        body: jsonEncode({...payload, 'userId': userId}),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getFeedbackForOrder(String orderId) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/feedback/$orderId"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMyFeedbacks({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/feedback?page=$page&limit=$limit"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Address APIs
  static Future<Map<String, dynamic>> getAddresses() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/address/all"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createAddress(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        Uri.parse("$baseUrl/address/create"),
        body: jsonEncode(payload),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> setDefaultAddress(String id) async {
    try {
      final response = await authenticatedRequest(
        'PATCH',
        Uri.parse("$baseUrl/address/$id/set-default"),
        body: jsonEncode({}),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteAddress(String id) async {
    try {
      final response = await authenticatedRequest(
        'DELETE',
        Uri.parse("$baseUrl/address/$id"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Save / refresh FCM push token on backend
  static Future<void> updateFcmToken(String token) async {
    try {
      await authenticatedRequest(
        'PATCH',
        Uri.parse("$baseUrl/users/fcm-token"),
        body: jsonEncode({'fcmToken': token}),
      );
    } catch (_) {}
  }

  /// ✅ Stripe payment intent — returns { clientSecret, paymentIntentId }
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    String currency = 'eur',
    String? orderId,
  }) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        Uri.parse("$baseUrl/payments/create-intent"),
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          if (orderId != null) 'orderId': orderId,
        }),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Payment method APIs
  static Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/payments/methods"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> savePaymentMethod(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        Uri.parse("$baseUrl/payments/methods"),
        body: jsonEncode(payload),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Notification APIs
  static Future<Map<String, dynamic>> getNotifications({String? userId}) async {
    try {
      final effectiveUserId = userId ?? await getUserId();
      if (effectiveUserId == null) {
        return {"success": false, "message": "User id missing"};
      }
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/notification/notifications/$effectiveUserId"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Statistics APIs
  static Future<Map<String, dynamic>> getStatistics({
    String period = "last10days",
  }) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/statistics?period=$period"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getEarningsStats({
    String period = "last10days",
  }) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/statistics/earnings?period=$period"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getOrdersStats({
    String period = "last10days",
  }) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/statistics/orders?period=$period"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ✅ Get Transporters list
  static Future<Map<String, dynamic>> getTransporters({
    int limit = 10,
    String? search,
  }) async {
    try {
      final params = <String, String>{'limit': '$limit'};
      if (search != null && search.isNotEmpty) params['search'] = search;
      final uri = Uri.parse(
        "$baseUrl/transporter/all",
      ).replace(queryParameters: params);
      final response = await authenticatedRequest('GET', uri);
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getNearbyTransporters({
    required double latitude,
    required double longitude,
    double radius = 10,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/transporter/transporters/nearby").replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radius': radius.toString(),
        },
      );
      final response = await authenticatedRequest('GET', uri);
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getBanners() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/banners"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getVehicleTypes() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/vehicle-types"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMyVehicles() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/vehicle/mine"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateOnlineStatus(bool isOnline) async {
    try {
      final response = await authenticatedRequest(
        'PATCH',
        Uri.parse("$baseUrl/transporter/online-status"),
        body: jsonEncode({"isOnline": isOnline}),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createVehicle({
    required String type,
    required String brand,
    required String registration,
    String? model,
  }) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        Uri.parse("$baseUrl/vehicle/create"),
        body: jsonEncode({
          "type": type,
          "brand": brand,
          "registration": registration,
          if (model != null && model.isNotEmpty) "model": model,
        }),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteVehicle(String vehicleId) async {
    try {
      final response = await authenticatedRequest(
        'DELETE',
        Uri.parse("$baseUrl/vehicle/$vehicleId"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> uploadVehicleProof(
    String vehicleId,
    String filePath,
  ) async {
    try {
      final token = await getAccessToken();
      final url = Uri.parse("$baseUrl/vehicle/$vehicleId/ownership-proof");
      debugPrint("🚀 API REQUEST [POST MULTIPART]: $url");
      final request = http.MultipartRequest(
        'POST',
        url,
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'proof',
          filePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      debugPrint("✅ API RESPONSE [POST MULTIPART] [$url]: ${response.statusCode}");
      debugPrint("📄 DATA: ${response.body}");
      return _normalizeResponse(response);
    } catch (e) {
      debugPrint("❌ API ERROR [UPLOAD VEHICLE PROOF]: $e");
      return {"success": false, "message": e.toString()};
    }
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
    await prefs.remove('userId');
  }

  /// ✅ Authenticated Helper
  static Future<http.Response> authenticatedRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    print("📡 authenticatedRequest: Preparing $method to $url");
    var token = await getAccessToken();
    headers ??= {};
    headers["Authorization"] = "Bearer $token";
    headers["Content-Type"] = "application/json";

    print("🚀 API REQUEST [$method]: $url");
    if (body != null) print("📦 BODY: $body");

    http.Response response;
    response = await _doRequest(method, url, headers: headers, body: body);

    print("✅ API RESPONSE [$method] [$url]: ${response.statusCode}");
    print("📄 DATA: ${response.body}");

    if (response.statusCode == 401) {
      debugPrint("⚠️ 401 Unauthorized - Attempting token refresh...");
      final success = await refreshTokens();
      if (success) {
        debugPrint("♻️ Token refresh success - Retrying original request");
        token = await getAccessToken();
        headers["Authorization"] = "Bearer $token";
        response = await _doRequest(method, url, headers: headers, body: body);
        debugPrint("✅ API RESPONSE (RETRY) [$method] [$url]: ${response.statusCode}");
        debugPrint("📄 DATA: ${response.body}");
        return response;
      } else {
        debugPrint("❌ Token refresh failed - Logging out");
        await logout();
        Get.offAllNamed('/login');
      }
    }
    return response;
  }

  static Future<http.Response> _doRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    switch (method) {
      case 'POST':
        return http.post(url, headers: headers, body: body);
      case 'PATCH':
        return http.patch(url, headers: headers, body: body);
      case 'PUT':
        return http.put(url, headers: headers, body: body);
      case 'DELETE':
        return http.delete(url, headers: headers);
      default:
        return http.get(url, headers: headers);
    }
  }

  /// ✅ Favorites APIs
  static Future<Map<String, dynamic>> getFavorites() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/favorites"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> removeFavorite(
    String transporterId,
  ) async {
    try {
      final response = await authenticatedRequest(
        'DELETE',
        Uri.parse("$baseUrl/transporter/$transporterId/favorite"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addFavorite(String transporterId) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        Uri.parse("$baseUrl/transporter/$transporterId/favorite"),
        body: jsonEncode({}),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> checkFavorite(
    String transporterId,
  ) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse("$baseUrl/transporter/$transporterId/favorite"),
      );
      return _normalizeResponse(response);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
