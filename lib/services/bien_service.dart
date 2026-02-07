import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bien.dart';
import '../models/bien_validation.dart';

class BienService {
  final String baseUrl = 'http://localhost:8000/api/v1/biens';

  // Méthode pour récupérer le token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Méthode pour construire les headers
  Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ========== MÉTHODES DE VALIDATION (ADMIN) ==========

  Future<List<Bien>> getBiensEnAttente() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/en-attente'), // URL CORRIGÉE
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Bien.fromJson(json)).toList();
      } else {
        print('❌ Erreur ${response.statusCode}: ${response.body}');
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur getBiensEnAttente: $e');
      rethrow;
    }
  }

  Future<Bien> validerBien(int id, BienValidationDto validationData) async {
    try {
      final token = await _getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/valider'),
        headers: _getHeaders(token),
        body: jsonEncode(validationData.toJson()),
      );

      if (response.statusCode == 200) {
        return Bien.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Erreur ${response.statusCode}: ${response.body}');
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur validerBien: $e');
      rethrow;
    }
  }

  Future<int> getStatsBiensEnAttente() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/stats/en-attente'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('❌ Erreur getStatsBiensEnAttente: $e');
      return 0;
    }
  }

  // ========== MÉTHODES PUBLIQUES ==========

  Future<List<Bien>> getBiensPublics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/publics'));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Bien.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getBiensPublics: $e');
      return [];
    }
  }

  Future<Bien?> getBienById(int id) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        return Bien.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('❌ Erreur getBienById: $e');
      return null;
    }
  }

  Future<List<Bien>> getAllBiens() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Bien.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getAllBiens: $e');
      return [];
    }
  }

  Future<List<Bien>> getBiensByProprietaire(int proprietaireId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/proprietaire/$proprietaireId'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Bien.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getBiensByProprietaire: $e');
      return [];
    }
  }

  // ========== CRÉATION DE BIEN ==========

  Future<Bien?> createBien(Map<String, dynamic> bienData, String token) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bienData),
      );

      if (response.statusCode == 201) {
        return Bien.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('❌ Erreur createBien: $e');
      rethrow;
    }
  }

  // VERSION MULTIPART AVEC PHOTOS
  Future<Bien?> creerBienMultipart({
    required Map<String, dynamic> bienData,
    List<File>? photos,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Ajouter les données JSON
      request.fields['bien'] = jsonEncode(bienData);

      // Ajouter les photos si elles existent
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'photos',
              photo.path,
            ),
          );
        }
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        return Bien.fromJson(json.decode(responseData));
      } else {
        final errorBody = await response.stream.bytesToString();
        print('❌ Erreur ${response.statusCode}: $errorBody');
        throw Exception('Erreur ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      print('❌ Erreur creerBienMultipart: $e');
      rethrow;
    }
  }

  // ========== RECHERCHE ==========

  Future<List<Bien>> searchBiens({
    String? ville,
    String? type,
    double? prixMin,
    double? prixMax,
  }) async {
    try {
      String query = '';
      if (ville != null && ville.isNotEmpty) query += 'ville=$ville&';
      if (type != null && type.isNotEmpty) query += 'typeBien=$type&';
      if (prixMin != null) query += 'prixMin=$prixMin&';
      if (prixMax != null) query += 'prixMax=$prixMax';

      // Supprimer le dernier & si présent
      if (query.endsWith('&')) {
        query = query.substring(0, query.length - 1);
      }

      final url = Uri.parse('$baseUrl/recherche/avancee?$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Bien.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur searchBiens: $e');
      return [];
    }
  }

  // ========== MISE À JOUR ==========

  Future<Bien?> updateBien({
    required int id,
    required Map<String, dynamic> bienData,
    List<File>? photos,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id'));
      request.headers['Authorization'] = 'Bearer $token';

      // Ajouter les données JSON
      request.fields['bien'] = jsonEncode(bienData);

      // Ajouter les photos si elles existent
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'photos',
              photo.path,
            ),
          );
        }
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return Bien.fromJson(json.decode(responseData));
      } else {
        final errorBody = await response.stream.bytesToString();
        print('❌ Erreur ${response.statusCode}: $errorBody');
        throw Exception('Erreur ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      print('❌ Erreur updateBien: $e');
      rethrow;
    }
  }

  // ========== SUPPRESSION ==========

  Future<bool> deleteBien(int id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(token),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('❌ Erreur deleteBien: $e');
      rethrow;
    }
  }

  // ========== CHANGEMENT DE STATUT ==========

  Future<Bien> changerStatutBien(int id, String statut) async {
    try {
      final token = await _getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/statut'),
        headers: _getHeaders(token),
        body: jsonEncode({'statut': statut}),
      );

      if (response.statusCode == 200) {
        return Bien.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur changerStatutBien: $e');
      rethrow;
    }
  }

}