import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../../services/persistence_service.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final int statusCode;
  final dynamic details;

  ApiException({
    required this.code,
    required this.message,
    required this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ApiException [$code] (HTTP $statusCode): $message';
}

class ApiClient {
  final PersistenceService persistence;
  final http.Client _httpClient;
  final String _baseUrl;

  bool _isRefreshing = false;

  ApiClient({
    required this.persistence,
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  String? get accessToken => persistence.getAccessToken();
  String? get refreshToken => persistence.getRefreshToken();

  Map<String, String> _buildHeaders({bool requiresAuth = true, String? contentType = 'application/json'}) {
    final headers = <String, String>{};
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    if (requiresAuth && accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams, bool requiresAuth = true}) async {
    final uri = _buildUri(path, queryParams);
    return _sendWithRetry(() => _httpClient.get(uri, headers: _buildHeaders(requiresAuth: requiresAuth)));
  }

  Future<dynamic> post(String path, {dynamic body, bool requiresAuth = true}) async {
    final uri = _buildUri(path);
    final payload = body != null ? jsonEncode(body) : null;
    return _sendWithRetry(() => _httpClient.post(uri, headers: _buildHeaders(requiresAuth: requiresAuth), body: payload));
  }

  Future<dynamic> patch(String path, {dynamic body, bool requiresAuth = true}) async {
    final uri = _buildUri(path);
    final payload = body != null ? jsonEncode(body) : null;
    return _sendWithRetry(() => _httpClient.patch(uri, headers: _buildHeaders(requiresAuth: requiresAuth), body: payload));
  }

  Future<dynamic> delete(String path, {dynamic body, bool requiresAuth = true}) async {
    final uri = _buildUri(path);
    final payload = body != null ? jsonEncode(body) : null;
    return _sendWithRetry(() => _httpClient.delete(uri, headers: _buildHeaders(requiresAuth: requiresAuth), body: payload));
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$_baseUrl$cleanPath';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
    }
    return uri;
  }

  Future<dynamic> _sendWithRetry(Future<http.Response> Function() requestFn) async {
    try {
      final response = await requestFn().timeout(const Duration(seconds: 15));

      if (response.statusCode == 401 && refreshToken != null && !_isRefreshing) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          // Retry original request once
          final retryResponse = await requestFn().timeout(const Duration(seconds: 15));
          return _parseResponse(retryResponse);
        }
      }

      return _parseResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Cannot connect to backend server. Please check your internet connection.',
        statusCode: 0,
        details: e.message,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'REQUEST_FAILED',
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return decoded['data'];
        }
        return decoded;
      } catch (_) {
        return response.body;
      }
    }

    String errorCode = 'API_ERROR';
    String errorMessage = 'Request failed with status ${response.statusCode}';
    dynamic details;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded.containsKey('error')) {
        final err = decoded['error'];
        errorCode = err['code'] ?? errorCode;
        errorMessage = err['message'] ?? errorMessage;
        details = err['details'];
      }
    } catch (_) {}

    throw ApiException(
      code: errorCode,
      message: errorMessage,
      statusCode: response.statusCode,
      details: details,
    );
  }

  Future<bool> _tryRefreshToken() async {
    _isRefreshing = true;
    try {
      final currentRefreshToken = refreshToken;
      if (currentRefreshToken == null) return false;

      final uri = _buildUri('/auth/refresh');
      final res = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': currentRefreshToken}),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['success'] == true) {
          final data = decoded['data'];
          await persistence.saveTokens(
            accessToken: data['accessToken'],
            refreshToken: data['refreshToken'],
          );
          return true;
        }
      }

      // If refresh failed, clear tokens
      await persistence.clearTokens();
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
