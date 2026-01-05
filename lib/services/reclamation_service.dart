// lib/services/reclamation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reclamation.dart';
import 'api_service.dart';

class ReclamationService {
  final ApiService _apiService = ApiService();

  Future<List<Reclamation>> getMesReclamations() async {
    try {
      final response = await _apiService.get('/api/v1/reclamations/mes-reclamations');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Reclamation.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur getMesReclamations: $e');
      rethrow;
    }
  }

  /// lib/services/reclamation_service.dart - CORRECTION pour getReclamationsByContrat
  Future<List<Reclamation>> getReclamationsByContrat(int contratId) async {
    try {
      print('🔄 Chargement réclamations pour contrat: $contratId');

      final response = await _apiService.get('/api/v1/reclamations/contrat/$contratId');

      print('📥 Réponse brute: ${response.statusCode}');
      print('📥 Corps réponse: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Vérifiez la structure de la réponse
        print('📊 Structure réponse:');
        print('  success: ${data['success']}');
        print('  message: ${data['message']}');
        print('  data type: ${data['data']?.runtimeType}');

        if (data['success'] == true) {
          final List<dynamic> reclamationsList = data['data'] as List<dynamic>;
          print('✅ ${reclamationsList.length} réclamation(s) trouvée(s)');

          return reclamationsList.map((json) => Reclamation.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Erreur serveur');
        }
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur getReclamationsByContrat: $e');
      rethrow;
    }
  }

  // Dans ReclamationService, change l'URL :
  /// lib/services/reclamation_service.dart - CORRECTION MINIMALE
  /// lib/services/reclamation_service.dart - VERSION FINALE CORRIGÉE
  Future<Reclamation> creerReclamation({
    required String titre,
    required String description,
    required String type,
    required String priorite,
    required int contratId,
  }) async {
    try {
      // Corps de la requête CORRECT
      final body = {
        'titre': titre,
        'description': description,
        'typeReclamation': type.toUpperCase(), // CORRIGÉ: 'typeReclamation'
        'priorite': priorite.toUpperCase(),    // 'BASSE', 'MOYENNE', 'HAUTE', 'URGENTE'
        'contratId': contratId,
      };

      print('📤 Envoi requête création réclamation:');
      print('   URL: /api/v1/reclamations/simple');
      print('   Body: ${json.encode(body)}');

      final response = await _apiService.post(
        '/api/v1/reclamations/simple',
        body: body,
      );

      print('📥 Réponse serveur: ${response.statusCode}');
      print('📥 Corps réponse: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Reclamation.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Erreur serveur');
        }
      } else {
        final errorBody = response.body;
        print('❌ Erreur ${response.statusCode}: $errorBody');
        throw Exception('Erreur ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      print('❌ Erreur creerReclamation: $e');
      rethrow;
    }
  }
}