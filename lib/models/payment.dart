// models/paiement.dart - ADAPTÉ À VOTRE BACKEND
import 'dart:ui';

import 'package:flutter/material.dart';

class Paiement {
  final int id;
  final String reference;
  final int contratId;
  final int locataireId;
  final double montantLoyer;
  final double montantCharges;
  final double montantTotal;
  final DateTime moisConcerne;
  final DateTime? dateEcheance;
  final String statut; // 'PENDING', 'CAPTURED', 'FAILED'
  final String currency;
  final DateTime createdAt;
  final DateTime? capturedAt;
  final String? modePaiement;
  final String? referenceTransaction;

  Paiement({
    required this.id,
    required this.reference,
    required this.contratId,
    required this.locataireId,
    required this.montantLoyer,
    required this.montantCharges,
    required this.montantTotal,
    required this.moisConcerne,
    this.dateEcheance,
    required this.statut,
    this.currency = 'MAD',
    required this.createdAt,
    this.capturedAt,
    this.modePaiement,
    this.referenceTransaction,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id']?.toInt() ?? json['ID_Paiement'],
      reference: json['reference'] ?? json['Reference'],
      contratId: json['contrat']?['id']?.toInt() ??
          json['contratId']?.toInt() ??
          json['ID_Contrat'],
      locataireId: json['locataire']?['id']?.toInt() ??
          json['locataireId']?.toInt() ??
          json['ID_Locataire'],
      montantLoyer: double.parse((json['montantLoyer'] ?? 0).toString()),
      montantCharges: double.parse((json['montantCharges'] ?? 0).toString()),
      montantTotal: double.parse((json['montantTotal'] ?? 0).toString()),
      moisConcerne: DateTime.parse(json['moisConcerne'] ?? json['mois_concerne']),
      dateEcheance: json['dateEcheance'] != null
          ? DateTime.parse(json['dateEcheance'] ?? json['date_echeance'])
          : null,
      statut: json['status'] ?? json['statut'] ?? 'PENDING',
      currency: json['currency'] ?? 'MAD',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      capturedAt: json['capturedAt'] != null
          ? DateTime.parse(json['capturedAt'] ?? json['captured_at'])
          : null,
      modePaiement: json['modePaiement'] ?? json['mode_paiement'],
      referenceTransaction: json['referenceTransaction'] ?? json['reference_transaction'],
    );
  }

  String get periode {
    final mois = moisConcerne.month;
    final annee = moisConcerne.year;
    final moisList = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${moisList[mois - 1]} $annee';
  }

  bool get estCaptured => statut == 'CAPTURED';
  bool get estPending => statut == 'PENDING';
  bool get estFailed => statut == 'FAILED';

  bool get estEnRetard {
    if (estCaptured) return false;
    final maintenant = DateTime.now();
    final dateLimite = dateEcheance ?? moisConcerne.add(const Duration(days: 35));
    return maintenant.isAfter(dateLimite);
  }

  Color get couleurStatut {
    switch (statut) {
      case 'CAPTURED': return Colors.green;
      case 'FAILED': return Colors.red;
      case 'PENDING': return estEnRetard ? Colors.red : Colors.orange;
      default: return Colors.grey;
    }
  }

  String get libelleStatut {
    switch (statut) {
      case 'CAPTURED': return 'Payé';
      case 'FAILED': return 'Échoué';
      case 'PENDING': return estEnRetard ? 'En retard' : 'En attente';
      default: return statut;
    }
  }
}

