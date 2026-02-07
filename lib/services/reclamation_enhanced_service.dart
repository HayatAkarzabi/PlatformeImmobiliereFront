// lib/services/reclamation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reclamation-detail.dart';
import '../models/reclamation-detail.dart';

class ReclamationService {
  final String baseUrl = 'http://localhost:8000/api/v1/reclamations';

  Future<List<ReclamationDetail>> getReclamations() async {
    try {
      print('🔄 Chargement des réclamations depuis API...');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('✅ Structure de réponse:');
          print('  success: ${data['success']}');
          print('  message: ${data['message']}');
          print('  data type: ${data['data']?.runtimeType}');

          if (data['success'] == true && data['data'] is List) {
            final List<dynamic> reclamations = data['data'];
            print('📊 Nombre de réclamations: ${reclamations.length}');

            // Debug: Afficher la première réclamation
            if (reclamations.isNotEmpty) {
              final first = reclamations.first;
              print('🔍 Première réclamation structure:');
              if (first is Map) {
                first.forEach((key, value) {
                  print('    $key: ${value?.toString() ?? "null"} (${value?.runtimeType})');
                });
              }
            }

            final List<ReclamationDetail> result = [];
            for (var item in reclamations) {
              try {
                if (item is Map<String, dynamic>) {
                  final reclamation = ReclamationDetail.fromJson(item);
                  result.add(reclamation);
                  print('✅ Réclamation parsée: ${reclamation.id} - ${reclamation.titre}');
                }
              } catch (e) {
                print('❌ Erreur parsing réclamation: $e');
                print('❌ Données problématiques: $item');
              }
            }

            return result;
          }
        } catch (e) {
          print('❌ Erreur parsing JSON: $e');
          print('❌ Raw response: ${response.body}');
        }
      } else {
        print('❌ Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur réseau: $e');
    }

    return []; // Retourne une liste vide en cas d'erreur
  }

  Future<List<ReclamationDetail>> getReclamationsTest() async {
    print('🧪 Utilisation des données de test');

    return [
      ReclamationDetail(
        id: 1,
        titre: 'Fuite d\'eau dans la salle de bain',
        description: 'Il y a une fuite d\'eau importante sous le lavabo qui cause des dégâts.',
        statut: 'EN_ATTENTE',
        priorite: 'URGENTE',
        typeReclamation: 'PLOMBERIE',
        dateCreation: DateTime.now().subtract(const Duration(days: 1)),
        locataireNom: 'Jean Dupont',
        locataireEmail: 'jean.dupont@email.com',
        locataireTelephone: '06 12 34 56 78',
        bienAdresse: '123 Rue de la République, 75001 Paris',
        contratReference: 'CONTRAT-2024-001',
      ),
      ReclamationDetail(
        id: 2,
        titre: 'Chauffage en panne',
        description: 'Le chauffage ne fonctionne plus depuis hier soir.',
        statut: 'EN_COURS',
        priorite: 'HAUTE',
        typeReclamation: 'CHAUFFAGE',
        dateCreation: DateTime.now().subtract(const Duration(days: 2)),
        locataireNom: 'Marie Martin',
        locataireEmail: 'marie.martin@email.com',
        locataireTelephone: '06 87 65 43 21',
        bienAdresse: '45 Avenue des Champs-Élysées, 75008 Paris',
        contratReference: 'CONTRAT-2024-002',
        solution: 'Technicien programmé pour demain à 14h',
      ),
      ReclamationDetail(
        id: 3,
        titre: 'Ascenseur en panne',
        description: 'L\'ascenseur est bloqué au 3ème étage.',
        statut: 'EN_ATTENTE',
        priorite: 'URGENTE',
        typeReclamation: 'ASCENSEUR',
        dateCreation: DateTime.now().subtract(const Duration(hours: 3)),
        locataireNom: 'Pierre Durand',
        locataireEmail: 'pierre.durand@email.com',
        locataireTelephone: '06 45 67 89 01',
        bienAdresse: '78 Boulevard Haussmann, 75009 Paris',
        contratReference: 'CONTRAT-2024-003',
      ),
    ];
  }
}