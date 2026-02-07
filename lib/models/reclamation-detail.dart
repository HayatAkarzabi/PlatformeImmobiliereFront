// lib/models/reclamation_detail.dart
class ReclamationDetail {
  final int id;
  final String titre;
  final String description;
  final String statut;
  final String priorite;
  final String typeReclamation;
  final DateTime dateCreation;

  // Informations du locataire
  final String locataireNom;
  final String locataireEmail;
  final String locataireTelephone;

  // Informations du bien
  final String bienAdresse;
  final String contratReference;

  final String? solution;

  ReclamationDetail({
    required this.id,
    required this.titre,
    required this.description,
    required this.statut,
    required this.priorite,
    required this.typeReclamation,
    required this.dateCreation,
    required this.locataireNom,
    required this.locataireEmail,
    required this.locataireTelephone,
    required this.bienAdresse,
    required this.contratReference,
    this.solution,
  });

  // Factory pour créer à partir de JSON
  factory ReclamationDetail.fromJson(Map<String, dynamic> json) {
    return ReclamationDetail(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      titre: _getString(json, 'titre', 'Sans titre'),
      description: _getString(json, 'description', ''),
      statut: _convertStatut(_getString(json, 'statut', 'EN_ATTENTE')),
      priorite: _convertPriorite(_getString(json, 'priorite', 'MOYENNE')),
      typeReclamation: _getString(json, 'typeReclamation', 'AUTRE'),
      dateCreation: _getDateTime(json, 'dateCreation'),

      // Informations du locataire
      locataireNom: _extractLocataireNom(json),
      locataireEmail: _extractLocataireEmail(json),
      locataireTelephone: _extractLocataireTelephone(json),

      // Informations du bien
      bienAdresse: _extractBienAdresse(json),
      contratReference: _extractContratReference(json),

      solution: json['solution']?.toString(),
    );
  }

  // Méthodes helpers pour extraction sécurisée
  static String _getString(Map<String, dynamic> json, String key, String defaultValue) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  static DateTime _getDateTime(Map<String, dynamic> json, String key) {
    try {
      final value = json[key];
      if (value == null) return DateTime.now();
      if (value is String) {
        return DateTime.parse(value);
      }
      if (value is DateTime) return value;
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static String _extractLocataireNom(Map<String, dynamic> json) {
    // Essayer plusieurs chemins possibles
    if (json['locataireNom'] != null) return json['locataireNom'].toString();
    if (json['locataire'] != null && json['locataire'] is Map) {
      final locataire = json['locataire'] as Map<String, dynamic>;
      if (locataire['nomComplet'] != null) return locataire['nomComplet'].toString();
      if (locataire['nom'] != null && locataire['prenom'] != null) {
        return '${locataire['prenom']} ${locataire['nom']}';
      }
      if (locataire['nom'] != null) return locataire['nom'].toString();
    }
    return 'Inconnu';
  }

  static String _extractLocataireEmail(Map<String, dynamic> json) {
    if (json['locataireEmail'] != null) return json['locataireEmail'].toString();
    if (json['locataire'] != null && json['locataire'] is Map) {
      final locataire = json['locataire'] as Map<String, dynamic>;
      if (locataire['email'] != null) return locataire['email'].toString();
    }
    return 'Non disponible';
  }

  static String _extractLocataireTelephone(Map<String, dynamic> json) {
    if (json['locataireTelephone'] != null) return json['locataireTelephone'].toString();
    if (json['locataire'] != null && json['locataire'] is Map) {
      final locataire = json['locataire'] as Map<String, dynamic>;
      if (locataire['telephone'] != null) return locataire['telephone'].toString();
    }
    return 'Non disponible';
  }

  static String _extractBienAdresse(Map<String, dynamic> json) {
    if (json['bienAdresse'] != null) return json['bienAdresse'].toString();
    if (json['bien'] != null && json['bien'] is Map) {
      final bien = json['bien'] as Map<String, dynamic>;
      if (bien['adresse'] != null) return bien['adresse'].toString();
      if (bien['adresseComplete'] != null) return bien['adresseComplete'].toString();
    }
    return 'Adresse non disponible';
  }

  static String _extractContratReference(Map<String, dynamic> json) {
    if (json['contratReference'] != null) return json['contratReference'].toString();
    if (json['contrat'] != null && json['contrat'] is Map) {
      final contrat = json['contrat'] as Map<String, dynamic>;
      if (contrat['reference'] != null) return contrat['reference'].toString();
    }
    return 'N/A';
  }

  static String _convertStatut(String statut) {
    final statutUpper = statut.toUpperCase();
    if (statutUpper.contains('OUVERTE')) return 'EN_ATTENTE';
    if (statutUpper.contains('EN_ATTENTE')) return 'EN_ATTENTE';
    if (statutUpper.contains('EN_COURS')) return 'EN_COURS';
    if (statutUpper.contains('RESOLUE')) return 'RESOLUE';
    if (statutUpper.contains('FERMEE')) return 'FERMEE';
    return statutUpper;
  }

  static String _convertPriorite(String priorite) {
    final prioriteUpper = priorite.toUpperCase();
    if (prioriteUpper.contains('URGENTE')) return 'URGENTE';
    if (prioriteUpper.contains('HAUTE')) return 'HAUTE';
    if (prioriteUpper.contains('BASSE')) return 'BASSE';
    return 'MOYENNE';
  }

  String get formattedDate {
    return '${dateCreation.day.toString().padLeft(2, '0')}/'
        '${dateCreation.month.toString().padLeft(2, '0')}/'
        '${dateCreation.year} ${dateCreation.hour.toString().padLeft(2, '0')}:'
        '${dateCreation.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'statut': statut,
      'priorite': priorite,
      'typeReclamation': typeReclamation,
      'dateCreation': dateCreation.toIso8601String(),
      'locataireNom': locataireNom,
      'locataireEmail': locataireEmail,
      'locataireTelephone': locataireTelephone,
      'bienAdresse': bienAdresse,
      'contratReference': contratReference,
      'solution': solution,
    };
  }

  @override
  String toString() {
    return 'ReclamationDetail(id: $id, titre: $titre, locataire: $locataireNom, statut: $statut)';
  }
}