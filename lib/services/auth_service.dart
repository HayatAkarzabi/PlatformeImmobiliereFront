// services/auth_service.dart - VERSION CORRIGÉE
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  final http.Client client;

  AuthService() : client = http.Client();

  // LOGIN
  Future<String> login(String email, String password) async {
    print('🔐 Login attempt for: $email');

    try {
      final response = await client.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📥 Response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['token'];

        if (token.isEmpty) {
          throw Exception('No token received');
        }

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, token);

        print('✅ Login successful! Token saved.');
        print('🔑 Token: ${token.substring(0, min(30, token.length))}...');
        return token;
      } else {
        throw Exception('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  // GET PROFILE
  Future<User> getProfile() async {
    try {
      print('🔄 Récupération du profil...');

      final token = await getToken();
      if (token == null) {
        throw Exception('Not logged in');
      }

      // Essayer différents endpoints
      final endpoints = [
        '${AppConstants.baseUrl}/api/profile/me',
        '${AppConstants.baseUrl}/api/users/me',
        '${AppConstants.baseUrl}/user/profile',
      ];

      for (final endpoint in endpoints) {
        try {
          print('🌐 Test endpoint: $endpoint');

          final response = await client.get(
            Uri.parse(endpoint),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 5));

          print('📊 Status Code: ${response.statusCode}');

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = jsonDecode(response.body);
            print('✅ Profil récupéré depuis $endpoint');
            print('📄 Données: $data');

            // Créer l'utilisateur selon le format de réponse
            return User(
              id: data['id'] ?? 0,
              firstName: data['firstName'] ?? data['firstname'] ?? data['nom'] ?? 'Utilisateur',
              lastName: data['lastName'] ?? data['lastname'] ?? data['prenom'] ?? '',
              email: data['email'] ?? data['Email'] ?? '',
              phone: data['phone'] ?? data['telephone'] ?? data['Phone'] ?? '',
              adresse: data['adresse'] ?? data['address'] ?? data['Adresse'] ?? '',
              type: data['type'] ?? data['role'] ?? data['Type'] ?? 'LOCATAIRE',
              token: token,
            );
          }
        } catch (e) {
          print('⚠️ Erreur sur $endpoint: $e');
        }
      }

      // Si aucun endpoint ne fonctionne, créer depuis token
      print('🔄 Création du profil depuis le token...');
      return _createUserFromToken(token);

    } catch (e) {
      print('❌ Erreur getProfile: $e');
      rethrow;
    }
  }

  // Créer User depuis token JWT
  User _createUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Token JWT invalide');

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded);

      print('🔍 Token décodé: $payloadMap');

      return User(
        id: payloadMap['id'] ?? payloadMap['ID_Personne'] ?? 0,
        firstName: payloadMap['sub']?.split('@').first ??
            payloadMap['firstName'] ??
            payloadMap['Nom'] ??
            'Utilisateur',
        lastName: payloadMap['lastName'] ?? payloadMap['Prenom'] ?? '',
        email: payloadMap['sub'] ??
            payloadMap['email'] ??
            payloadMap['Email'] ??
            'email@example.com',
        phone: payloadMap['phone'] ?? payloadMap['Telephone'] ?? '',
        adresse: payloadMap['adresse'] ?? payloadMap['Adresse'] ?? '',
        type: payloadMap['role'] ?? payloadMap['type'] ?? payloadMap['Type'] ?? 'LOCATAIRE',
        token: token,
      );
    } catch (e) {
      print('❌ Erreur décodage token: $e');
      return User(
        id: 0,
        firstName: 'Utilisateur',
        lastName: '',
        email: 'user@example.com',
        phone: '',
        adresse: '',
        type: 'LOCATAIRE',
        token: token,
      );
    }
  }

  // GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.authTokenKey);
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    print('✅ Déconnecté - Token supprimé');
  }

  // CHECK IF LOGGED IN
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // REGISTER
  Future<String> register(Map<String, dynamic> userData) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, token);

        return token;
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}