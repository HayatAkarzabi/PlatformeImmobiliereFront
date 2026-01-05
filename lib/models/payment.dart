class Paiement {
  final int id;
  final String reference;
  final int contratId;
  final int locataireId;
  final int bienId;
  final double montantTotal;
  final DateTime moisConcerne;
  final DateTime? dateEcheance;
  final DateTime? datePaiement;
  final String statut;
  final String? modePaiement;
  final String? referenceTransaction;

  Paiement({
    required this.id,
    required this.reference,
    required this.contratId,
    required this.locataireId,
    required this.bienId,
    required this.montantTotal,
    required this.moisConcerne,
    this.dateEcheance,
    this.datePaiement,
    required this.statut,
    this.modePaiement,
    this.referenceTransaction,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'],
      reference: json['reference'],
      contratId: json['contratId'],
      locataireId: json['locataireId'],
      bienId: json['bienId'],
      montantTotal: double.parse(json['montantTotal'].toString()),
      moisConcerne: DateTime.parse(json['moisConcerne']),
      dateEcheance: json['dateEcheance'] != null
          ? DateTime.parse(json['dateEcheance'])
          : null,
      datePaiement: json['datePaiement'] != null
          ? DateTime.parse(json['datePaiement'])
          : null,
      statut: json['statut'],
      modePaiement: json['modePaiement'],
      referenceTransaction: json['referenceTransaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'contratId': contratId,
      'locataireId': locataireId,
      'bienId': bienId,
      'montantTotal': montantTotal,
      'moisConcerne': moisConcerne.toIso8601String(),
      'dateEcheance': dateEcheance?.toIso8601String(),
      'datePaiement': datePaiement?.toIso8601String(),
      'statut': statut,
      'modePaiement': modePaiement,
      'referenceTransaction': referenceTransaction,
    };
  }

  String get periode {
    final moisList = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${moisList[moisConcerne.month - 1]} ${moisConcerne.year}';
  }

  bool get estPaye => statut == 'PAYE';
  bool get estEnAttente => statut == 'EN_ATTENTE';
  bool get estEnRetard => statut == 'EN_RETARD';
}