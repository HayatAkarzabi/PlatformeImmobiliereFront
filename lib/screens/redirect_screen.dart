// lib/screens/admin/debug_admin_test.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DebugAdminTestScreen extends StatefulWidget {
  const DebugAdminTestScreen({super.key});

  @override
  State<DebugAdminTestScreen> createState() => _DebugAdminTestScreenState();
}

class _DebugAdminTestScreenState extends State<DebugAdminTestScreen> {
  final String baseUrl = 'http://localhost:8000';
  String _debugInfo = 'Chargement...';
  String _userType = 'Inconnu';

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _debugInfo = '❌ Aucun token trouvé - Déconnecté';
          _userType = 'DÉCONNECTÉ';
        });
        return;
      }

      // Test 1: Vérifier le token
      _debugInfo = '🔑 Token trouvé: ${token.substring(0, 20)}...\n\n';

      // Test 2: Récupérer le profil
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _debugInfo += '📡 Statut API: ${response.statusCode}\n\n';

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final type = data['type'] ?? 'NON DÉFINI';

        setState(() {
          _userType = type.toString().toUpperCase();
          _debugInfo += '''
✅ PROFIL RÉCUPÉRÉ:

ID: ${data['id']}
Email: ${data['email']}
Nom: ${data['firstName']} ${data['lastName']}
Type: $type
Type (uppercase): ${type.toString().toUpperCase()}

🔍 TESTS:

Est ADMIN: ${type.toString().toUpperCase() == 'ADMIN'}
Est PROPRIETAIRE: ${type.toString().toUpperCase() == 'PROPRIETAIRE'}
Est LOCATAIRE: ${type.toString().toUpperCase() == 'LOCATAIRE'}

📋 Données complètes:
${jsonEncode(data)}
''';
        });
      } else {
        setState(() {
          _debugInfo += '❌ Erreur API: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _debugInfo = '❌ Exception: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Admin Test'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              color: Colors.yellow[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.bug_report, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Type utilisateur détecté:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userType,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _userType == 'ADMIN' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _debugInfo,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Forcer la redirection admin
                Navigator.pushReplacementNamed(context, '/admin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('FORCER REDIRECTION ADMIN'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/proprietaire/dashboard');
              },
              child: const Text('Aller vers Propriétaire'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _checkUserType,
              child: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }
}