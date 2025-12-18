import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void testBackendConnection(BuildContext context) {
  final url = 'http://localhost:8000/simple-test/hello';

  http.get(Uri.parse(url)).then((response) {
    if (response.statusCode == 200) {
      // SUCCÈS !
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ Connexion réussie !'),
          content: Text('Backend répond: ${response.body}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // ÉCHEC
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Connexion échouée'),
          content: Text('Erreur ${response.statusCode}: ${response.body}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }).catchError((error) {
    // ERREUR RÉSEAU
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Erreur réseau'),
        content: Text('Impossible de joindre le backend:\n$error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  });
}