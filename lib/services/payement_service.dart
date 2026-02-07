// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class PaymentService {
//   static const String baseUrl = 'http://192.168.1.100:8000';
//
//   static Future<Map<String, dynamic>> _makeRequest(
//       String method,
//       String endpoint,
//       Map<String, dynamic>? body,
//       String? authToken,
//       ) async {
//     final url = Uri.parse('$baseUrl$endpoint');
//     final headers = {
//       'Content-Type': 'application/json',
//       if (authToken != null && authToken.isNotEmpty)
//         'Authorization': 'Bearer $authToken',
//     };
//
//     http.Response response;
//     try {
//       switch (method.toUpperCase()) {
//         case 'POST':
//           response = await http.post(
//             url,
//             headers: headers,
//             body: body != null ? jsonEncode(body) : null,
//           );
//           break;
//         case 'GET':
//           response = await http.get(url, headers: headers);
//           break;
//         default:
//           throw Exception('Méthode HTTP non supportée: $method');
//       }
//
//       final data = jsonDecode(utf8.decode(response.bodyBytes));
//
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         return {'success': true, 'data': data};
//       } else {
//         return {
//           'success': false,
//           'error': data['error'] ?? 'Erreur serveur ${response.statusCode}'
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'error': 'Erreur de connexion: $e'
//       };
//     }
//   }
//
//   // Initialiser un paiement
//   static Future<Map<String, dynamic>> initPayment({
//     required int contratId,
//     required int userId,
//     required String authToken,
//     String? moisConcerne,
//     String paymentMethod = 'CREDIT_CARD',
//     String? cardNumber,
//     String? cardExpiry,
//     String? cardCVV,
//   }) async {
//     return await _makeRequest(
//       'POST',
//       '/payments/init',
//       {
//         'contratId': contratId,
//         'userId': userId,
//         'moisConcerne': moisConcerne ?? _getCurrentMonthDate(),
//         'paymentMethod': paymentMethod,
//         if (cardNumber != null) 'cardNumber': cardNumber.replaceAll(' ', ''),
//         if (cardExpiry != null) 'cardExpiry': cardExpiry,
//         if (cardCVV != null) 'cardCVV': cardCVV,
//       },
//       authToken,
//     );
//   }
//
//   // Capturer un paiement
//   static Future<Map<String, dynamic>> capturePayment({
//     required int paymentId,
//     required String authToken,
//   }) async {
//     return await _makeRequest(
//       'POST',
//       '/payments/$paymentId/capture',
//       null,
//       authToken,
//     );
//   }
//
//   // Annuler un paiement
//   static Future<Map<String, dynamic>> cancelPayment({
//     required int paymentId,
//     required String authToken,
//   }) async {
//     return await _makeRequest(
//       'POST',
//       '/payments/$paymentId/cancel',
//       null,
//       authToken,
//     );
//   }
//
//   // Obtenir l'historique des paiements
//   static Future<Map<String, dynamic>> getPaymentHistory({
//     required int contratId,
//     required String authToken,
//   }) async {
//     return await _makeRequest(
//       'GET',
//       '/payments/contrat/$contratId',
//       null,
//       authToken,
//     );
//   }
//
//   // Obtenir les paiements d'un locataire
//   static Future<Map<String, dynamic>> getPaymentsByLocataire({
//     required int locataireId,
//     required String authToken,
//   }) async {
//     return await _makeRequest(
//       'GET',
//       '/payments/locataire/$locataireId',
//       null,
//       authToken,
//     );
//   }
//
//   // Tester la connexion
//   static Future<bool> testConnection() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/payments/test'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 5));
//
//       return response.statusCode == 200;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   static String _getCurrentMonthDate() {
//     final now = DateTime.now();
//     return '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = 'http://localhost:8000';

  // Activer/désactiver les logs
  static bool debugMode = true;

  static void _log(String message) {
    if (debugMode) {
      print('🔍 [PaymentService] $message');
    }
  }

  static Future<Map<String, dynamic>> _makeRequest(
      String method,
      String endpoint,
      Map<String, dynamic>? body,
      String? authToken,
      ) async {
    final url = Uri.parse('$baseUrl$endpoint');

    _log('=== NOUVELLE REQUÊTE ===');
    _log('Méthode: $method');
    _log('URL: $url');
    _log('Token: ${authToken != null ? "PRÉSENT (${authToken.length} chars)" : "ABSENT"}');
    if (body != null) {
      _log('Body: ${jsonEncode(body)}');
    } else {
      _log('Body: Aucun');
    }

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };

    _log('Headers: $headers');

    try {
      _log('Envoi de la requête...');

      http.Response response;
      final startTime = DateTime.now();

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 30));
          break;
        case 'GET':
          response = await http.get(
            url,
            headers: headers,
          ).timeout(const Duration(seconds: 30));
          break;
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }

      final duration = DateTime.now().difference(startTime);

      _log('=== RÉPONSE REÇUE ===');
      _log('Durée: ${duration.inMilliseconds}ms');
      _log('Status Code: ${response.statusCode}');
      _log('Headers: ${response.headers}');

      // Log du body (limité à 500 caractères pour éviter de flooder)
      final bodyString = utf8.decode(response.bodyBytes);
      if (bodyString.length > 500) {
        _log('Body (tronqué): ${bodyString.substring(0, 500)}...');
      } else {
        _log('Body: $bodyString');
      }

      dynamic data;
      try {
        data = jsonDecode(bodyString);
      } catch (e) {
        _log('❌ Erreur parsing JSON: $e');
        data = {'raw': bodyString};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _log('✅ Requête réussie');
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        _log('❌ Erreur serveur: ${response.statusCode}');
        return {
          'success': false,
          'error': data['error'] ?? data['message'] ?? 'Erreur serveur ${response.statusCode}',
          'statusCode': response.statusCode,
          'data': data,
        };
      }
    } catch (e) {
      _log('❌ ERREUR DE CONNEXION: $e');
      _log('Type d\'erreur: ${e.runtimeType}');

      if (e is http.ClientException) {
        _log('ClientException: ${e.message}');
        _log('URI: ${e.uri}');
      }

      return {
        'success': false,
        'error': 'Erreur de connexion: ${e.toString()}',
        'type': e.runtimeType.toString(),
      };
    } finally {
      _log('=== FIN REQUÊTE ===\n');
    }
  }

  // Initialiser un paiement
  static Future<Map<String, dynamic>> initPayment({
    required int contratId,
    required int userId,
    required String authToken,
    String? moisConcerne,
    String paymentMethod = 'CREDIT_CARD',
    String? cardNumber,
    String? cardExpiry,
    String? cardCVV,
  }) async {
    _log('=== INIT PAYMENT ===');
    _log('Contrat ID: $contratId');
    _log('User ID: $userId');
    _log('Mois concerné: ${moisConcerne ?? _getCurrentMonthDate()}');
    _log('Méthode de paiement: $paymentMethod');

    return await _makeRequest(
      'POST',
      '/payments/init',
      {
        'contratId': contratId,
        'userId': userId,
        'moisConcerne': moisConcerne ?? _getCurrentMonthDate(),
        'paymentMethod': paymentMethod,
        if (cardNumber != null) 'cardNumber': cardNumber.replaceAll(' ', ''),
        if (cardExpiry != null) 'cardExpiry': cardExpiry,
        if (cardCVV != null) 'cardCVV': cardCVV,
      },
      authToken,
    );
  }

  // Capturer un paiement
  static Future<Map<String, dynamic>> capturePayment({
    required int paymentId,
    required String authToken,
  }) async {
    _log('=== CAPTURE PAYMENT ===');
    _log('Payment ID: $paymentId');

    return await _makeRequest(
      'POST',
      '/payments/$paymentId/capture',
      null,
      authToken,
    );
  }

  // Annuler un paiement
  static Future<Map<String, dynamic>> cancelPayment({
    required int paymentId,
    required String authToken,
  }) async {
    _log('=== CANCEL PAYMENT ===');
    _log('Payment ID: $paymentId');

    return await _makeRequest(
      'POST',
      '/payments/$paymentId/cancel',
      null,
      authToken,
    );
  }

  // Obtenir l'historique des paiements
  static Future<Map<String, dynamic>> getPaymentHistory({
    required int contratId,
    required String authToken,
  }) async {
    _log('=== GET PAYMENT HISTORY ===');
    _log('Contrat ID: $contratId');

    return await _makeRequest(
      'GET',
      '/payments/contrat/$contratId',
      null,
      authToken,
    );
  }

  // Obtenir les paiements d'un locataire
  static Future<Map<String, dynamic>> getPaymentsByLocataire({
    required int locataireId,
    required String authToken,
  }) async {
    _log('=== GET PAYMENTS BY LOCATAIRE ===');
    _log('Locataire ID: $locataireId');

    return await _makeRequest(
      'GET',
      '/payments/locataire/$locataireId',
      null,
      authToken,
    );
  }

  // Obtenir les paiements en attente
  static Future<Map<String, dynamic>> getPendingPayments({
    required String authToken,
  }) async {
    _log('=== GET PENDING PAYMENTS ===');

    return await _makeRequest(
      'GET',
      '/payments/en-attente',
      null,
      authToken,
    );
  }

  // Obtenir les paiements en retard
  static Future<Map<String, dynamic>> getOverduePayments({
    required String authToken,
  }) async {
    _log('=== GET OVERDUE PAYMENTS ===');

    return await _makeRequest(
      'GET',
      '/payments/en-retard',
      null,
      authToken,
    );
  }

  // Télécharger une quittance
  static Future<Map<String, dynamic>> downloadReceipt({
    required int paymentId,
    required String authToken,
  }) async {
    _log('=== DOWNLOAD RECEIPT ===');
    _log('Payment ID: $paymentId');

    final url = Uri.parse('$baseUrl/payments/receipt/$paymentId');

    _log('URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _log('✅ Quittance téléchargée (${response.bodyBytes.length} bytes)');
        return {
          'success': true,
          'data': response.bodyBytes,
          'contentType': response.headers['content-type'],
        };
      } else {
        _log('❌ Erreur téléchargement: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Erreur ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      _log('❌ Erreur téléchargement: $e');
      return {
        'success': false,
        'error': 'Erreur de téléchargement: $e',
      };
    }
  }

  // Tester la connexion avec plus de détails
  static Future<Map<String, dynamic>> testConnection() async {
    _log('=== TEST CONNEXION ===');
    _log('URL de base: $baseUrl');

    final testUrls = [
      '/payments/test',
      '/payments',
      '/api/v1/contrats/mes-contrats',
    ];

    final results = <String, dynamic>{};

    for (final endpoint in testUrls) {
      final url = Uri.parse('$baseUrl$endpoint');
      _log('Test URL: $url');

      try {
        final startTime = DateTime.now();
        final response = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        final duration = DateTime.now().difference(startTime);

        results[endpoint] = {
          'status': response.statusCode,
          'time': '${duration.inMilliseconds}ms',
          'success': response.statusCode < 400,
          'body': response.body.length > 100
              ? '${response.body.substring(0, 100)}...'
              : response.body,
        };

        _log('  $endpoint: ${response.statusCode} (${duration.inMilliseconds}ms)');
      } catch (e) {
        results[endpoint] = {
          'status': 'ERROR',
          'error': e.toString(),
          'success': false,
        };
        _log('  $endpoint: ❌ $e');
      }
    }

    final allSuccessful = results.values.every((r) => r['success'] == true);

    return {
      'success': allSuccessful,
      'results': results,
      'baseUrl': baseUrl,
      'timestamp': DateTime.now().toString(),
    };
  }

  // Méthode pour tester avec différentes adresses IP
  static Future<Map<String, dynamic>> testAllConnections() async {
    _log('=== TEST TOUTES LES CONNEXIONS ===');

    final testUrls = [
      'http://192.168.1.100:8000',  // Votre IP actuelle
      'http://10.0.2.2:8000',       // Émulateur Android
      'http://localhost:8000',       // iOS Simulator
      'http://127.0.0.1:8000',       // Localhost
    ];

    final results = <String, dynamic>{};

    for (final testUrl in testUrls) {
      _log('Test: $testUrl');

      try {
        final url = Uri.parse('$testUrl/payments/test');
        final response = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        results[testUrl] = {
          'status': response.statusCode,
          'success': response.statusCode == 200,
          'body': response.body,
        };

        _log('  $testUrl: ${response.statusCode}');
      } catch (e) {
        results[testUrl] = {
          'status': 'ERROR',
          'error': e.toString(),
          'success': false,
        };
        _log('  $testUrl: ❌ $e');
      }
    }

    return {
      'success': results.values.any((r) => r['success'] == true),
      'results': results,
      'bestUrl': results.entries
          .firstWhere((e) => e.value['success'] == true, orElse: () => results.entries.first)
          .key,
    };
  }

  static String _getCurrentMonthDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  }
}