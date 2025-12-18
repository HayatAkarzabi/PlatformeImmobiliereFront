// services/demande_location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/demande_location.dart';
import 'storage_service.dart';

class DemandeLocationService {
  final String baseUrl;
  final StorageService storageService;

  DemandeLocationService({
    required this.baseUrl,
    required this.storageService,
  });

  Future<List<DemandeLocationResponse>> getMesDemandes() async {
    try {
      // CORRECTION: Utilise getToken() au lieu de getHeaders()
      final token = await storageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token non disponible');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/demandes/mes-demandes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DemandeLocationResponse.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}