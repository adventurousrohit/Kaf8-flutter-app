import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_endpoints.dart';

/// Low-level HTTP access to [ApiConfig.baseUrl]. Set [accessToken] after login
/// for `Authorization: Bearer …` on each request.
final class ApiClient {
  ApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  String? accessToken;

  void dispose() => _client.close();

  Map<String, String> _jsonHeaders() => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (accessToken != null && accessToken!.trim().isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      };

  Uri _uri(String path, {Map<String, String>? query}) {
    final u = ApiConfig.resolve(path);
    if (query == null || query.isEmpty) return u;
    return u.replace(queryParameters: {...u.queryParameters, ...query});
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) {
    return _client.get(
      _uri(path, query: query),
      headers: {..._jsonHeaders(), ...?headers},
    );
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) {
    return _client.post(
      _uri(path, query: query),
      headers: {..._jsonHeaders(), ...?headers},
      body: _encodeBody(body),
    );
  }

  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) {
    return _client.put(
      _uri(path, query: query),
      headers: {..._jsonHeaders(), ...?headers},
      body: _encodeBody(body),
    );
  }

  Future<http.Response> patch(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) {
    return _client.patch(
      _uri(path, query: query),
      headers: {..._jsonHeaders(), ...?headers},
      body: _encodeBody(body),
    );
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) {
    return _client.delete(
      _uri(path, query: query),
      headers: {..._jsonHeaders(), ...?headers},
    );
  }

  /// JSON body except when [body] is already a [String].
  String? _encodeBody(Object? body) {
    if (body == null) return null;
    if (body is String) return body;
    return jsonEncode(body);
  }

  /// `multipart/form-data` (no JSON `Content-Type`). Use for register (avatar),
  /// order create (`photos`), vehicles (`photo`), etc.
  Future<http.Response> sendMultipart(
    String method,
    String path, {
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String>? query,
  }) async {
    final request = http.MultipartRequest(method, _uri(path, query: query));
    if (accessToken != null && accessToken!.trim().isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);
    request.files.addAll(files);
    final streamed = await _client.send(request);
    return http.Response.fromStream(streamed);
  }

  Future<http.Response> postMultipart(
    String path, {
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String>? query,
  }) {
    return sendMultipart(
      'POST',
      path,
      fields: fields,
      files: files,
      query: query,
    );
  }

  Future<http.Response> putMultipart(
    String path, {
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String>? query,
  }) {
    return sendMultipart(
      'PUT',
      path,
      fields: fields,
      files: files,
      query: query,
    );
  }
}
