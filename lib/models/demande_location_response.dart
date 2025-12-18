// lib/models/demande_location_response.dart
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

class DemandeLocationResponse {
  final int id;
  final int bienId;
  final String bienReference;
  final String bienAdresse;
  final String bienVille;
  final int locataireId;
  final String locataireNom;
  final String locataireEmail;
  final String locatairePhone;
  final DateTime dateDebut;
  final int dureeContrat;
  final String? message;
  final String statut;
  final String? motifRefus;
  final DateTime? dateTraitement;
  final DateTime dateCreation;
  final DateTime dateModification;

  DemandeLocationResponse({
    required this.id,
    required this.bienId,
    required this.bienReference,
    required this.bienAdresse,
    required this.bienVille,
    required this.locataireId,
    required this.locataireNom,
    required this.locataireEmail,
    required this.locatairePhone,
    required this.dateDebut,
    required this.dureeContrat,
    this.message,
    required this.statut,
    this.motifRefus,
    this.dateTraitement,
    required this.dateCreation,
    required this.dateModification,
  });

  factory DemandeLocationResponse.fromJson(Map<String, dynamic> json) {
    return DemandeLocationResponse(
      id: json['id'] as int,
      bienId: json['bienId'] as int,
      bienReference: json['bienReference'] as String,
      bienAdresse: json['bienAdresse'] as String,
      bienVille: json['bienVille'] as String,
      locataireId: json['locataireId'] as int,
      locataireNom: json['locataireNom'] as String,
      locataireEmail: json['locataireEmail'] as String,
      locatairePhone: json['locatairePhone'] as String,
      dateDebut: DateTime.parse(json['dateDebut'] as String),
      dureeContrat: json['dureeContrat'] as int,
      message: json['message'] as String?,
      statut: json['statut'] as String,
      motifRefus: json['motifRefus'] as String?,
      dateTraitement: json['dateTraitement'] != null
          ? DateTime.parse(json['dateTraitement'] as String)
          : null,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateModification: DateTime.parse(json['dateModification'] as String),
    );
  }

  // Méthode utilitaire pour obtenir la couleur du statut
  Color get statutColor {
    switch (statut.toUpperCase()) {
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'ACCEPTEE':
        return Colors.green;
      case 'REFUSEE':
        return Colors.red;
      case 'ANNULEE':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  // Méthode utilitaire pour obtenir le libellé du statut
  String get statutLabel {
    switch (statut.toUpperCase()) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'ACCEPTEE':
        return 'Acceptée';
      case 'REFUSEE':
        return 'Refusée';
      case 'ANNULEE':
        return 'Annulée';
      default:
        return statut;
    }
  }

  // Formater la date de début
  String get formattedDateDebut {
    return '${dateDebut.day}/${dateDebut.month}/${dateDebut.year}';
  }

  // Formater la date de création
  String get formattedDateCreation {
    return '${dateCreation.day}/${dateCreation.month}/${dateCreation.year}';
  }
}// TODO Implement this library.