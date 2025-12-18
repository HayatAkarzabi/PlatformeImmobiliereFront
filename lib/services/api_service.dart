// // services/api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../utils/constants.dart';
//
// class ApiService {
//   final http.Client client;
//
//   ApiService() : client = http.Client();
//
//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(AppConstants.authTokenKey);
//
//     if (token == null) return null;
//
//     // NETTOYAGE ESSENTIEL
//     return token
//         .replaceAll('\n', '')     // Enlever les sauts de ligne
//         .replaceAll('\r', '')     // Enlever les retours chariot
//         .replaceAll(' ', '')      // Enlever les espaces
//         .trim();
//   }
//   // GET avec token
//   Future<http.Response> get(String endpoint) async {
//     final token = await _getToken();
//     print('🔑 GET - Token disponible: ${token != null}');
//
//     final headers = <String, String>{
//       'Content-Type': 'application/json',
//     };
//
//     // AJOUTER LE TOKEN DANS LES HEADERS
//     if (token != null) {
//       headers['Authorization'] = 'Bearer $token';
//       print('🔑 Token envoyé: ${token.substring(0, 20)}...');
//     }
//
//     final url = '${AppConstants.baseUrl}$endpoint';
//     print('🌐 GET: $url');
//     print('📤 Headers: $headers');
//
//     try {
//       final response = await client.get(
//         Uri.parse(url),
//         headers: headers,
//       ).timeout(const Duration(seconds: 10));
//
//       print('📥 Response: ${response.statusCode}');
//       return response;
//     } catch (e) {
//       print('❌ GET Error: $e');
//       rethrow;
//     }
//   }
//
//   // POST avec token
//   Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
//     final token = await _getToken();
//
//     final headers = <String, String>{
//       'Content-Type': 'application/json',
//     };
//
//     if (token != null) {
//       headers['Authorization'] = 'Bearer $token';
//     }
//
//     print('🌐 POST: ${AppConstants.baseUrl}$endpoint');
//
//     return client.post(
//       Uri.parse('${AppConstants.baseUrl}$endpoint'),
//       headers: headers,
//       body: body != null ? jsonEncode(body) : null,
//     );
//   }
//
//   // PUT avec token
//   Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
//     final token = await _getToken();
//
//     final headers = <String, String>{
//       'Content-Type': 'application/json',
//     };
//
//     if (token != null) {
//       headers['Authorization'] = 'Bearer $token';
//     }
//
//     return client.put(
//       Uri.parse('${AppConstants.baseUrl}$endpoint'),
//       headers: headers,
//       body: body != null ? jsonEncode(body) : null,
//     );
//   }
//
//   // DELETE avec token
//   Future<http.Response> delete(String endpoint) async {
//     final token = await _getToken();
//
//     final headers = <String, String>{
//       'Content-Type': 'application/json',
//     };
//
//     if (token != null) {
//       headers['Authorization'] = 'Bearer $token';
//     }
//
//     return client.delete(
//       Uri.parse('${AppConstants.baseUrl}$endpoint'),
//       headers: headers,
//     );
//   }
// }

// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  final http.Client client;

  ApiService() : client = http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);

    if (token == null) return null;

    // NETTOYAGE ESSENTIEL
    return token
        .replaceAll('\n', '')     // Enlever les sauts de ligne
        .replaceAll('\r', '')     // Enlever les retours chariot
        .replaceAll(' ', '')      // Enlever les espaces
        .trim();
  }

  // GET avec token
  Future<http.Response> get(String endpoint) async {
    final token = await _getToken();
    print('🔑 GET - Token disponible: ${token != null}');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // AJOUTER LE TOKEN DANS LES HEADERS
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('🔑 Token envoyé: ${token.substring(0, 20)}...');
    }

    final url = '${AppConstants.baseUrl}$endpoint';
    print('🌐 GET: $url');
    print('📤 Headers: $headers');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('📥 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }

  // POST avec token - Version améliorée
  Future<http.Response> post(String endpoint, {dynamic body}) async {
    final token = await _getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('🔑 Token envoyé dans POST: ${token.substring(0, 20)}...');
    }

    final url = '${AppConstants.baseUrl}$endpoint';
    print('🌐 POST: $url');
    print('📤 Headers: $headers');

    String? jsonBody;

    // Gérer différents types de body
    if (body != null) {
      if (body is Map<String, dynamic> || body is List) {
        jsonBody = jsonEncode(body);
      } else if (body is String) {
        jsonBody = body;
      } else {
        throw ArgumentError('Unsupported body type: ${body.runtimeType}');
      }

      print('📦 Request Body: $jsonBody');
    }

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonBody,
      ).timeout(const Duration(seconds: 10));

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }

  // PUT avec token
  Future<http.Response> put(String endpoint, {dynamic body}) async {
    final token = await _getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final url = '${AppConstants.baseUrl}$endpoint';
    print('🌐 PUT: $url');

    String? jsonBody;

    if (body != null) {
      if (body is Map<String, dynamic> || body is List) {
        jsonBody = jsonEncode(body);
      } else if (body is String) {
        jsonBody = body;
      }

      print('📦 Request Body: $jsonBody');
    }

    try {
      final response = await client.put(
        Uri.parse(url),
        headers: headers,
        body: jsonBody,
      ).timeout(const Duration(seconds: 10));

      print('📥 Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ PUT Error: $e');
      rethrow;
    }
  }

  // DELETE avec token
  Future<http.Response> delete(String endpoint) async {
    final token = await _getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final url = '${AppConstants.baseUrl}$endpoint';
    print('🌐 DELETE: $url');

    try {
      final response = await client.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('📥 Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ DELETE Error: $e');
      rethrow;
    }
  }

  // Méthode utilitaire pour créer les headers
  Map<String, String> _createHeaders({bool withAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    return headers;
  }
}