/// lib/models/reclamation.dart - VERSION CORRIGÉE
import 'package:flutter/material.dart';

class Reclamation {
  final int id;
  final String titre;
  final String description;
  final String typeRec; // CORRIGÉ: Un seul champ pour le type
  final String statut; // OUVERTE, EN_COURS, RESOLUE, ANNULEE
  final String priorite; // BASSE, MOYENNE, HAUTE, URGENTE
  final int contratId;
  final String contratReference;
  final DateTime dateCreation;
  final DateTime? dateResolution;
  final List<String>? photos;

  Reclamation({
    required this.id,
    required this.titre,
    required this.description,
    required this.typeRec, // CORRIGÉ: typeRec (pas type)
    required this.statut,
    required this.priorite,
    required this.contratId,
    required this.contratReference,
    required this.dateCreation,
    this.dateResolution,
    this.photos,
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'] as int? ?? 0,
      titre: (json['titre'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      typeRec: (json['typeReclamation'] ?? 'NORMAL') as String, // typeReclamation dans JSON
      statut: (json['statut'] ?? 'OUVERTE') as String,
      priorite: (json['priorite'] ?? 'MOYENNE') as String,
      contratId: json['contratId'] as int? ?? 0,
      contratReference: (json['contratReference'] ?? 'N/A') as String,
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'] as String)
          : DateTime.now(),
      dateResolution: json['dateResolution'] != null
          ? DateTime.tryParse(json['dateResolution'] as String)
          : null,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'])
          : null,
    );
  }

  // Getters pour l'UI - UTILISEZ typeRec maintenant
  Color get statutColor {
    switch (statut) {
      case 'OUVERTE': return Colors.orange;
      case 'EN_COURS': return Colors.blue;
      case 'RESOLUE': return Colors.green;
      case 'ANNULEE': return Colors.grey;
      default: return Colors.black;
    }
  }

  String get statutText {
    switch (statut) {
      case 'OUVERTE': return 'Ouverte';
      case 'EN_COURS': return 'En cours';
      case 'RESOLUE': return 'Résolue';
      case 'ANNULEE': return 'Annulée';
      default: return statut;
    }
  }

  // CORRIGÉ: Utilisez typeRec pour les getters du type
  String get typeText {
    switch (typeRec) {
      case 'PLOMBERIE': return 'Plomberie';
      case 'ELECTRICITE': return 'Électricité';
      case 'CHAUFFAGE': return 'Chauffage';
      case 'CLIMATISATION': return 'Climatisation';
      case 'SERRURERIE': return 'Serrurerie';
      case 'AUTRE': return 'Autre';
      default: return typeRec;
    }
  }

  Color get typeColor {
    switch (typeRec) {
      case 'PLOMBERIE': return Colors.blue;
      case 'ELECTRICITE': return Colors.amber;
      case 'CHAUFFAGE': return Colors.orange;
      case 'CLIMATISATION': return Colors.cyan;
      case 'SERRURERIE': return Colors.brown;
      case 'AUTRE': return Colors.grey;
      default: return Colors.blue;
    }
  }

  Color get prioriteColor {
    switch (priorite) {
      case 'URGENTE': return Colors.red[900]!;
      case 'HAUTE': return Colors.red;
      case 'MOYENNE': return Colors.orange;
      case 'BASSE': return Colors.green;
      default: return Colors.grey;
    }
  }

  String get prioriteText {
    switch (priorite) {
      case 'URGENTE': return 'Urgente';
      case 'HAUTE': return 'Haute';
      case 'MOYENNE': return 'Moyenne';
      case 'BASSE': return 'Basse';
      default: return priorite;
    }
  }
}