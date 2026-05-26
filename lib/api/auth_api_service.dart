import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_endpoints.dart';

/// Shared by **Customer** and **Service provider** apps (login, register, tokens).
final class AuthApiService {
  AuthApiService(this._client);

  final ApiClient _client;

  Future<http.Response> updateRole({
    required String userId,
    required String role,
  }) {
    return _client.post(
      ApiEndpoints.authUpdateRole,
      body: {'userId': userId, 'role': role},
    );
  }

  /// Backend expects `multipart/form-data` with optional file field `avatar`.
  Future<http.Response> register({
    required Map<String, String> fields,
    http.MultipartFile? avatar,
  }) {
    return _client.postMultipart(
      ApiEndpoints.authRegister,
      fields: fields,
      files: [if (avatar != null) avatar],
    );
  }

  /// Body: `{ "identifier": emailOrPhone, "password": "…" }`
  Future<http.Response> login({
    required String identifier,
    required String password,
  }) {
    return _client.post(
      ApiEndpoints.authLogin,
      body: {'identifier': identifier, 'password': password},
    );
  }

  Future<http.Response> forgotPassword({
    String? email,
    String? userId,
    String? phoneNumber,
  }) {
    return _client.post(
      ApiEndpoints.authForgotPassword,
      body: {
        if (email != null) 'email': email,
        if (userId != null) 'userId': userId,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      },
    );
  }

  Future<http.Response> sendOtp({
    required String userId,
    required String phoneNumber,
  }) {
    return _client.post(
      ApiEndpoints.authSendOtp,
      body: {'userId': userId, 'phoneNumber': phoneNumber},
    );
  }

  Future<http.Response> verifyOtp(Object body) =>
      _client.post(ApiEndpoints.authVerifyOtp, body: body);

  Future<http.Response> verifyResetCode(Object body) =>
      _client.post(ApiEndpoints.authVerifyResetCode, body: body);

  Future<http.Response> resetPassword(Object body) =>
      _client.post(ApiEndpoints.authResetPassword, body: body);

  Future<http.Response> refreshToken(Object body) =>
      _client.post(ApiEndpoints.authRefreshToken, body: body);
}
