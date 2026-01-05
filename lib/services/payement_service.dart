import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Utilisez 10.0.2.2 pour l'émulateur Android, 192.168.1.100 pour appareil physique
  static const String baseUrl = 'http://192.168.1.100:8000';
  // Pas besoin de apiPrefix si votre endpoint est directement /payments
  static const String apiPrefix = '';

  // Singleton pour gérer le token
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<Map<String, dynamic>> initPayment({
    required int contratId,
    required int userId,
    required String paymentMethod,
    String? cardNumber,
    String? cardExpiry,
    String? cardCVV,
  }) async {
    final url = Uri.parse('$baseUrl/payments/init'); // URL directe

    final headers = {
      'Content-Type': 'application/json',
    };

    // Ajouter le token s'il existe
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'contratId': contratId,
        'userId': userId,
        'moisConcerne': _getCurrentMonthDate(), // Format correct
        'paymentMethod': paymentMethod,
        'cardNumber': cardNumber,
        'cardExpiry': cardExpiry,
        'cardCVV': cardCVV,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Échec de l\'initialisation du paiement: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> capturePayment(int paymentId) async {
    final url = Uri.parse('$baseUrl/payments/$paymentId/capture');

    final headers = {
      'Content-Type': 'application/json',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final response = await http.post(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Échec de la capture: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> cancelPayment(int paymentId) async {
    final url = Uri.parse('$baseUrl/payments/$paymentId/cancel');

    final headers = {
      'Content-Type': 'application/json',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final response = await http.post(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Échec de l\'annulation: ${response.statusCode} - ${response.body}');
    }
  }

  // Méthode pour obtenir l'historique des paiements
  Future<List<dynamic>> getPaymentHistory(int contratId) async {
    final url = Uri.parse('$baseUrl/payments/contrat/$contratId');

    final headers = {};
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Échec de récupération: ${response.statusCode}');
    }
  }

  // Méthode pour tester la connexion
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/payments/init');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }

  // Helper pour le format de date
  String _getCurrentMonthDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  }
}