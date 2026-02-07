class Payment {
  final int id;
  final String reference;
  final String status;
  final double montantTotal;
  final DateTime moisConcerne;
  final DateTime? dateEcheance;
  final DateTime? capturedAt;
  final String? modePaiement;
  final String? receiptUrl;

  Payment({
    required this.id,
    required this.reference,
    required this.status,
    required this.montantTotal,
    required this.moisConcerne,
    this.dateEcheance,
    this.capturedAt,
    this.modePaiement,
    this.receiptUrl,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toInt() ?? 0,
      reference: json['reference'] ?? '',
      status: json['status'] ?? 'PENDING',
      montantTotal: (json['montantTotal'] is num)
          ? (json['montantTotal'] as num).toDouble()
          : double.tryParse(json['montantTotal']?.toString() ?? '0') ?? 0.0,
      moisConcerne: DateTime.tryParse(json['moisConcerne']?.toString() ?? '') ?? DateTime.now(),
      dateEcheance: json['dateEcheance'] != null
          ? DateTime.tryParse(json['dateEcheance'].toString())
          : null,
      capturedAt: json['capturedAt'] != null
          ? DateTime.tryParse(json['capturedAt'].toString())
          : null,
      modePaiement: json['modePaiement'],
      receiptUrl: json['receiptUrl'] ?? json['receiptUrlStr'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'status': status,
    'montantTotal': montantTotal,
    'moisConcerne': moisConcerne.toIso8601String(),
    'dateEcheance': dateEcheance?.toIso8601String(),
    'capturedAt': capturedAt?.toIso8601String(),
    'modePaiement': modePaiement,
    'receiptUrl': receiptUrl,
  };

  bool get estPaye => status == 'CAPTURED' || status == 'PAYE';
  bool get estEnAttente => status == 'PENDING';
  bool get estEnRetard => status == 'EN_RETARD';

  String get periode {
    final moisList = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${moisList[moisConcerne.month - 1]} ${moisConcerne.year}';
  }
}