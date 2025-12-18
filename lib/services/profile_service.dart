import 'dart:convert';
import '../services/api_service.dart';
import '../models/user.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  /// GET /api/profile/me
  Future<User> getProfile() async {
    final response = await _apiService.get('/api/profile/me');

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Impossible de charger le profil');
    }
  }

  /// PUT /api/profile/update
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String adresse,
  }) async {
    final response = await _apiService.put(
      '/api/profile/update',
      body: {
        "prenom": firstName,
        "nom": lastName,
        "telephone": phone,
        "adresse": adresse,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour');
    }
  }

  /// PUT /api/profile/password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.put(
      '/api/profile/password',
      body: {
        "oldPassword": currentPassword,
        "newPassword": newPassword,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Mot de passe incorrect');
    }
  }
}
