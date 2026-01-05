import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/bien.dart';

class BienService {
  final String baseUrl = 'http://localhost:8000/api/v1/biens';


  Future<List<Bien>> getBiensPublics() async {
    final response = await http.get(Uri.parse('$baseUrl/publics'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Bien.fromJson(json)).toList();
    }
    return [];
  }

  Future<Bien?> getBienById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Bien.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Bien?> createBien(Map<String, dynamic> bienData, String token) async {
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
  }

  Future<List<Bien>> searchBiens({String? ville, String? type}) async {
    String query = '';
    if (ville != null) query += 'ville=$ville&';
    if (type != null) query += 'typeBien=$type';
    final response = await http.get(Uri.parse('$baseUrl/recherche/avancee?$query'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Bien.fromJson(json)).toList();
    }
    return [];
  }
  static Future<Bien?> creerBien({
    required Map<String, dynamic> bienData,
    List<File>? photos,
    required String token,
  }) async {
    try {
      if (photos != null && photos.isNotEmpty) {
        // Avec photos - requête multipart
        var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
        request.headers['Authorization'] = 'Bearer $token';

        // Ajouter les données JSON
        request.fields['bien'] = json.encode(bienData);

        // Ajouter les photos
        for (var photo in photos) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'photos',
              photo.path,
            ),
          );
        }

        final response = await request.send();
        if (response.statusCode == 201) {
          final responseData = await response.stream.bytesToString();
          return Bien.fromJson(json.decode(responseData));
        }
      } else {
        // Sans photos - requête JSON simple
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(bienData),
        );

        if (response.statusCode == 201) {
          return Bien.fromJson(json.decode(response.body));
        }
      }
      return null;
    } catch (e) {
      print('Erreur création bien: $e');
      rethrow;
    }
  }



}


