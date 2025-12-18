// lib/models/demande_location.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum StatutDemande {
  EN_ATTENTE,
  ACCEPTEE,
  REFUSEE,
  ANNULEE;

  String get displayName {
    switch (this) {
      case StatutDemande.EN_ATTENTE:
        return 'En attente';
      case StatutDemande.ACCEPTEE:
        return 'Acceptée';
      case StatutDemande.REFUSEE:
        return 'Refusée';
      case StatutDemande.ANNULEE:
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }

  Color get color {
    switch (this) {
      case StatutDemande.EN_ATTENTE:
        return Colors.orange;
      case StatutDemande.ACCEPTEE:
        return Colors.green;
      case StatutDemande.REFUSEE:
        return Colors.red;
      case StatutDemande.ANNULEE:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  IconData get icon {
    switch (this) {
      case StatutDemande.EN_ATTENTE:
        return Icons.access_time;
      case StatutDemande.ACCEPTEE:
        return Icons.check_circle;
      case StatutDemande.REFUSEE:
        return Icons.cancel;
      case StatutDemande.ANNULEE:
        return Icons.block;
      default:
        return Icons.help;
    }
  }
}

class DemandeLocationRequest {
  final int bienId;
  final DateTime dateDebut;
  final int dureeContrat;
  final String? message;

  DemandeLocationRequest({
    required this.bienId,
    required this.dateDebut,
    required this.dureeContrat,
    this.message,
  });

  Map<String, dynamic> toJson() => {
    'bienId': bienId,
    'dateDebut': DateFormat('yyyy-MM-dd').format(dateDebut),
    'dureeContrat': dureeContrat,
    'message': message,
  };
}

class DemandeLocationTraitementRequest {
  final String motifRefus;

  DemandeLocationTraitementRequest({
    required this.motifRefus,
  });

  Map<String, dynamic> toJson() => {
    'motifRefus': motifRefus,
  };
}

class DemandeLocationResponse {
  final int id;
  final int bienId;
  final String bienReference;
  final String bienAdresse;
  final String bienVille;
  final int? locataireId;
  final String? locataireNom;
  final String? locataireEmail;
  final String? locatairePhone;
  final DateTime dateDebut;
  final int dureeContrat;
  final String? message;
  final StatutDemande statut;
  final String? motifRefus;
  final DateTime? dateTraitement;
  final DateTime dateCreation;
  final DateTime? dateModification;

  DemandeLocationResponse({
    required this.id,
    required this.bienId,
    required this.bienReference,
    required this.bienAdresse,
    required this.bienVille,
    this.locataireId,
    this.locataireNom,
    this.locataireEmail,
    this.locatairePhone,
    required this.dateDebut,
    required this.dureeContrat,
    this.message,
    required this.statut,
    this.motifRefus,
    this.dateTraitement,
    required this.dateCreation,
    this.dateModification,
  });

  factory DemandeLocationResponse.fromJson(Map<String, dynamic> json) {
    return DemandeLocationResponse(
      id: json['id'] as int,
      bienId: json['bienId'] as int,
      bienReference: json['bienReference'] ?? '',
      bienAdresse: json['bienAdresse'] ?? '',
      bienVille: json['bienVille'] ?? '',
      locataireId: json['locataireId'] as int?,
      locataireNom: json['locataireNom'] as String?,
      locataireEmail: json['locataireEmail'] as String?,
      locatairePhone: json['locatairePhone'] as String?,
      dateDebut: DateTime.parse(json['dateDebut'] as String),
      dureeContrat: json['dureeContrat'] as int,
      message: json['message'] as String?,
      statut: _parseStatut(json['statut'] as String),
      motifRefus: json['motifRefus'] as String?,
      dateTraitement: json['dateTraitement'] != null
          ? DateTime.parse(json['dateTraitement'] as String)
          : null,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateModification: json['dateModification'] != null
          ? DateTime.parse(json['dateModification'] as String)
          : null,
    );
  }

  static StatutDemande _parseStatut(String statut) {
    switch (statut.toUpperCase()) {
      case 'EN_ATTENTE':
        return StatutDemande.EN_ATTENTE;
      case 'ACCEPTEE':
        return StatutDemande.ACCEPTEE;
      case 'REFUSEE':
        return StatutDemande.REFUSEE;
      case 'ANNULEE':
        return StatutDemande.ANNULEE;
      default:
        return StatutDemande.EN_ATTENTE;
    }
  }

  String get formattedDateDebut => DateFormat('dd/MM/yyyy').format(dateDebut);
  String get formattedDateCreation => DateFormat('dd/MM/yyyy HH:mm').format(dateCreation);
  String? get formattedDateTraitement => dateTraitement != null
      ? DateFormat('dd/MM/yyyy HH:mm').format(dateTraitement!)
      : null;

  bool get peutAnnuler => statut == StatutDemande.EN_ATTENTE;
  bool get estEnAttente => statut == StatutDemande.EN_ATTENTE;
  bool get estAcceptee => statut == StatutDemande.ACCEPTEE;
  bool get estRefusee => statut == StatutDemande.REFUSEE;
}