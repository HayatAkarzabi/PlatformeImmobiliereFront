// services/paiement_service.dart - ADAPTÉ À VOTRE BACKEND
import 'dart:convert';
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/payment.dart';
import '../models/quittance.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class PaiementService {
    final  _authService = AuthService();
  final http.Client _client = http.Client();

  // Récupérer les paiements d'un locataire
  Future<List<Paiement>> getPaiementsByLocataire(int locataireId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}/api/payments/locataire/$locataireId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Paiements - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('📄 Réponse paiements: $data');
        return data.map((json) => Paiement.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('⚠️ Endpoint non trouvé, utilisation données simulées');
        return getPaiementsSimules(locataireId);
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération paiements: $e');
      return getPaiementsSimules(locataireId);
    }
  }

  // Récupérer les paiements en retard
  Future<List<Paiement>> getPaiementsEnRetard(int locataireId) async {
    final allPaiements = await getPaiementsByLocataire(locataireId);
    return allPaiements.where((p) => p.estEnRetard).toList();
  }

  // Récupérer les quittances (payments capturés)
  Future<List<Quittance>> getQuittancesByLocataire(int locataireId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}/api/payments/locataire/$locataireId/captured'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Quittance.fromJson(json)).toList();
      }
      return getQuittancesSimulees(locataireId);
    } catch (e) {
      print('❌ Erreur récupération quittances: $e');
      return getQuittancesSimulees(locataireId);
    }
  }

  // Télécharger une quittance PDF
  Future<List?> downloadReceipt(int paymentId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}/api/payments/receipt/$paymentId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('❌ Erreur téléchargement quittance: $e');
      return null;
    }
  }

  // Initialiser un paiement
  Future<Paiement?> initPayment(int contratId, String paymentMethod) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final user = await _authService.getProfile();

      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}/api/payments/init'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': user.id,
          'contratId': contratId,
          'paymentMethod': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Paiement.fromJson(data);
      }
      return null;
    } catch (e) {
      print('❌ Erreur initialisation paiement: $e');
      return null;
    }
  }

  // Capturer un paiement
  Future<Paiement?> capturePayment(int paymentId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}/api/payments/$paymentId/capture'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Paiement.fromJson(data);
      }
      return null;
    } catch (e) {
      print('❌ Erreur capture paiement: $e');
      return null;
    }
  }

  // Obtenir les statistiques
  Future<Map<String, dynamic>> getStatistiquesPaiements(int locataireId) async {
    final paiements = await getPaiementsByLocataire(locataireId);

    final paiementsPayes = paiements.where((p) => p.estCaptured);
    final paiementsEnRetard = paiements.where((p) => p.estEnRetard);
    final paiementsEnAttente = paiements.where((p) => p.estPending && !p.estEnRetard);

    final totalPaye = paiementsPayes.fold(0.0, (sum, p) => sum + p.montantTotal);
    final totalEnRetard = paiementsEnRetard.fold(0.0, (sum, p) => sum + p.montantTotal);
    final totalEnAttente = paiementsEnAttente.fold(0.0, (sum, p) => sum + p.montantTotal);

    return {
      'totalPaye': totalPaye,
      'totalEnRetard': totalEnRetard,
      'totalEnAttente': totalEnAttente,
      'nombrePaye': paiementsPayes.length,
      'nombreEnRetard': paiementsEnRetard.length,
      'nombreEnAttente': paiementsEnAttente.length,
    };
  }

  // Données simulées en attendant le backend
  List<Paiement> getPaiementsSimules(int locataireId) {
    final maintenant = DateTime.now();
    final moisPrecedent = DateTime(maintenant.year, maintenant.month - 1);
    final moisSuivant = DateTime(maintenant.year, maintenant.month + 1);
    final moisRetard = DateTime(2024, 11, 1);

    return [
      Paiement(
        id: 1,
        reference: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        contratId: 1,
        locataireId: locataireId,
        montantLoyer: 3000.00,
        montantCharges: 500.00,
        montantTotal: 3500.00,
        moisConcerne: DateTime(maintenant.year, maintenant.month, 1),
        dateEcheance: DateTime(maintenant.year, maintenant.month, 5),
        capturedAt: DateTime(maintenant.year, maintenant.month, 3),
        statut: 'CAPTURED',
        currency: 'MAD',
        createdAt: DateTime(maintenant.year, maintenant.month - 1, 25),
        modePaiement: 'VIREMENT',
        referenceTransaction: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      ),
      Paiement(
        id: 2,
        reference: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}-2',
        contratId: 1,
        locataireId: locataireId,
        montantLoyer: 3000.00,
        montantCharges: 500.00,
        montantTotal: 3500.00,
        moisConcerne: moisPrecedent,
        dateEcheance: DateTime(moisPrecedent.year, moisPrecedent.month, 5),
        capturedAt: DateTime(moisPrecedent.year, moisPrecedent.month, 2),
        statut: 'CAPTURED',
        currency: 'MAD',
        createdAt: DateTime(moisPrecedent.year, moisPrecedent.month - 1, 25),
        modePaiement: 'CARTE',
        referenceTransaction: 'TRX-${DateTime.now().millisecondsSinceEpoch}-2',
      ),
      Paiement(
        id: 3,
        reference: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}-3',
        contratId: 1,
        locataireId: locataireId,
        montantLoyer: 3000.00,
        montantCharges: 500.00,
        montantTotal: 3500.00,
        moisConcerne: moisSuivant,
        dateEcheance: DateTime(moisSuivant.year, moisSuivant.month, 5),
        statut: 'PENDING',
        currency: 'MAD',
        createdAt: maintenant,
        modePaiement: null,
        referenceTransaction: null,
      ),
      Paiement(
        id: 4,
        reference: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}-4',
        contratId: 1,
        locataireId: locataireId,
        montantLoyer: 3000.00,
        montantCharges: 500.00,
        montantTotal: 3500.00,
        moisConcerne: moisRetard,
        dateEcheance: DateTime(2024, 11, 5),
        statut: 'PENDING',
        currency: 'MAD',
        createdAt: DateTime(2024, 10, 25),
        modePaiement: null,
        referenceTransaction: null,
      ),
    ];
  }

  List<Quittance> getQuittancesSimulees(int locataireId) {
    return [
      Quittance(
        paiementId: 1,
        reference: 'Q-2024-001',
        datePaiement: DateTime.now(),
        montantTotal: 3500.00,
        periode: '${_getMoisString(DateTime.now().month)} ${DateTime.now().year}',
        bienAdresse: '123 Rue Principale, Casablanca',
        nomProprietaire: 'M. Ahmed BENJELLOUN',
        nomLocataire: 'M. Karim ALAMI',
        urlQuittance: '/payments/receipt/1',
      ),
      Quittance(
        paiementId: 2,
        reference: 'Q-2024-002',
        datePaiement: DateTime(2024, 1, 10),
        montantTotal: 3500.00,
        periode: '${_getMoisString(1)} 2024',
        bienAdresse: '123 Rue Principale, Casablanca',
        nomProprietaire: 'M. Ahmed BENJELLOUN',
        nomLocataire: 'M. Karim ALAMI',
        urlQuittance: '/payments/receipt/2',
      ),
    ];
  }

  String _getMoisString(int mois) {
    final moisList = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return moisList[mois - 1];
  }
}
