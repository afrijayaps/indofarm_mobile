import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required this.client,
    required this.config,
    this.readToken,
  });

  final http.Client client;
  final AppConfig config;
  final String? Function()? readToken;

  Future<Map<String, dynamic>> get(String path) {
    return _send('GET', path);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${config.baseUrl}$path');
    final token = readToken?.call();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    late http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await client
              .get(uri, headers: headers)
              .timeout(Duration(seconds: config.timeoutSeconds));
          break;
        case 'POST':
          response = await client
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(Duration(seconds: config.timeoutSeconds));
          break;
        default:
          throw const ApiException('Unsupported request method');
      }
    } catch (_) {
      throw const ApiException(
        'Network request failed. Check connection and retry.',
      );
    }

    Map<String, dynamic> payload = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }

    final error = (payload['error'] as Map<String, dynamic>?) ?? {};
    throw ApiException(
      error['message']?.toString() ?? 'Unknown API error',
      code: error['code']?.toString(),
      statusCode: response.statusCode,
      meta: payload['meta'] is Map<String, dynamic>
          ? payload['meta'] as Map<String, dynamic>
          : null,
    );
  }
}
