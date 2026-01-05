// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  final http.Client client;
  final String baseUrl = AppConstants.baseUrl;

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

  // Méthode pour récupérer le token (publique pour usage externe)
  Future<String?> getToken() async {
    return await _getToken();
  }

  // Créer les headers avec token
  Future<Map<String, String>> _createHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET avec token
  Future<http.Response> get(String endpoint) async {
    final headers = await _createHeaders();
    final token = await _getToken();

    print('🔑 GET - Token disponible: ${token != null}');

    if (token != null) {
      print('🔑 Token envoyé: ${token.substring(0, min(20, token.length))}...');
    }

    final url = '$baseUrl$endpoint';
    print('🌐 GET: $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📥 Response: ${response.statusCode}');

      // Log pour debug
      if (response.statusCode >= 400) {
        print('❌ GET Error ${response.statusCode}: ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }

  // POST avec token
  Future<http.Response> post(String endpoint, {dynamic body}) async {
    final headers = await _createHeaders();
    final token = await _getToken();

    if (token != null) {
      print('🔑 Token envoyé dans POST: ${token.substring(0, min(20, token.length))}...');
    }

    final url = '$baseUrl$endpoint';
    print('🌐 POST: $url');

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
      ).timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode >= 400) {
        print('❌ POST Error ${response.statusCode}: ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }

  // POST multipart pour upload de fichiers
  Future<http.Response> postMultipart(
      String endpoint, Map<String, String> map, {
        Map<String, String>? fields,
        Map<String, String>? files, // chemin -> field name
        List<Map<String, dynamic>>? multipleFiles, // pour plusieurs fichiers dans un même field
      }) async {
    final token = await _getToken();

    print('📤 POST Multipart - Token disponible: ${token != null}');

    final url = Uri.parse('$baseUrl$endpoint');
    print('🌐 POST Multipart: $url');

    try {
      var request = http.MultipartRequest('POST', url);

      // Ajouter le token d'authentification
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print('🔑 Token envoyé: ${token.substring(0, min(20, token.length))}...');
      }

      // Ajouter les champs de formulaire
      if (fields != null) {
        fields.forEach((key, value) {
          request.fields[key] = value;
        });
        print('📝 Fields: $fields');
      }

      // Ajouter les fichiers simples (un fichier par field)
      if (files != null) {
        for (var entry in files.entries) {
          final filePath = entry.key;
          final fieldName = entry.value;

          try {
            final file = File(filePath);
            if (await file.exists()) {
              final fileStream = http.ByteStream(file.openRead());
              final fileLength = await file.length();

              final multipartFile = http.MultipartFile(
                fieldName,
                fileStream,
                fileLength,
                filename: file.path.split('/').last,
              );

              request.files.add(multipartFile);
              print('📎 File added: $filePath -> $fieldName (${fileLength} bytes)');
            } else {
              print('⚠️ File does not exist: $filePath');
            }
          } catch (e) {
            print('❌ Error adding file $filePath: $e');
          }
        }
      }

      // Ajouter plusieurs fichiers dans un même field (pour les photos de réclamation)
      if (multipleFiles != null) {
        for (var fileInfo in multipleFiles) {
          final filePath = fileInfo['path'] as String;
          final fieldName = fileInfo['field'] as String;

          try {
            final file = File(filePath);
            if (await file.exists()) {
              final fileStream = http.ByteStream(file.openRead());
              final fileLength = await file.length();

              final multipartFile = http.MultipartFile(
                fieldName,
                fileStream,
                fileLength,
                filename: file.path.split('/').last,
              );

              request.files.add(multipartFile);
              print('📎 Multiple file added: $filePath -> $fieldName (${fileLength} bytes)');
            } else {
              print('⚠️ File does not exist: $filePath');
            }
          } catch (e) {
            print('❌ Error adding multiple file $filePath: $e');
          }
        }
      }

      // Envoyer la requête
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));

      // Convertir en http.Response
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Multipart Response Status: ${response.statusCode}');
      print('📥 Multipart Response Body: ${response.body}');

      if (response.statusCode >= 400) {
        print('❌ Multipart Error ${response.statusCode}: ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ POST Multipart Error: $e');
      rethrow;
    }
  }

  // PUT avec token
  Future<http.Response> put(String endpoint, {dynamic body}) async {
    final headers = await _createHeaders();
    final token = await _getToken();

    if (token != null) {
      print('🔑 Token envoyé dans PUT: ${token.substring(0, min(20, token.length))}...');
    }

    final url = '$baseUrl$endpoint';
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
      ).timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode >= 400) {
        print('❌ PUT Error ${response.statusCode}: ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ PUT Error: $e');
      rethrow;
    }
  }

  // DELETE avec token
  Future<http.Response> delete(String endpoint) async {
    final headers = await _createHeaders();
    final token = await _getToken();

    if (token != null) {
      print('🔑 Token envoyé dans DELETE: ${token.substring(0, min(20, token.length))}...');
    }

    final url = '$baseUrl$endpoint';
    print('🌐 DELETE: $url');

    try {
      final response = await client.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode >= 400) {
        print('❌ DELETE Error ${response.statusCode}: ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ DELETE Error: $e');
      rethrow;
    }
  }

  // Méthode utilitaire pour parser la réponse JSON
  dynamic parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('❌ JSON Parse Error: $e');
        throw FormatException('Invalid JSON response');
      }
    } else {
      throw HttpException(
        'Request failed with status: ${response.statusCode}',
        uri: response.request?.url,
      );
    }
  }

  // Méthode pour valider si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // Méthode pour déconnecter (supprimer le token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    print('🔑 Token supprimé');
  }

  // Fonction utilitaire pour trouver le minimum de deux entiers
  int min(int a, int b) => a < b ? a : b;
  static int _min(int a, int b) => a < b ? a : b;

}


