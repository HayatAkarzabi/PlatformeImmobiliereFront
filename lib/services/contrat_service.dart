import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contrat.dart';

class ContratService {
  final String baseUrl = "http://localhost:8080/contrats";

  /// Récupérer les contrats d'un locataire
  Future<List<Contrat>> getContratsByLocataire(int locataireId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/locataire/$locataireId"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Contrat.fromJson(json)).toList();
    } else {
      throw Exception("Impossible de récupérer les contrats");
    }
  }

  /// Récupérer un contrat par ID
  Future<Contrat?> getContratById(int contratId) async {
    final response = await http.get(Uri.parse("$baseUrl/$contratId"));

    if (response.statusCode == 200) {
      return Contrat.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}
