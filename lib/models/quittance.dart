// models/quittance.dart
class Quittance {
  final int paiementId;
  final String reference;
  final DateTime datePaiement;
  final double montantTotal;
  final String periode;
  final String bienAdresse;
  final String nomProprietaire;
  final String nomLocataire;
  final String urlQuittance;

  Quittance({
    required this.paiementId,
    required this.reference,
    required this.datePaiement,
    required this.montantTotal,
    required this.periode,
    required this.bienAdresse,
    required this.nomProprietaire,
    required this.nomLocataire,
    required this.urlQuittance,
  });

  factory Quittance.fromJson(Map<String, dynamic> json) {
    return Quittance(
      paiementId: json['paiementId'] ?? json['paymentId'],
      reference: json['reference'] ?? json['Reference'],
      datePaiement: DateTime.parse(json['datePaiement'] ?? json['capturedAt']),
      montantTotal: double.parse(json['montantTotal'].toString()),
      periode: json['periode'] ?? '${DateTime.now().month}/${DateTime.now().year}',
      bienAdresse: json['bienAdresse'] ?? json['adresse'] ?? '',
      nomProprietaire: json['nomProprietaire'] ?? json['proprietaire'] ?? '',
      nomLocataire: json['nomLocataire'] ?? json['locataire'] ?? '',
      urlQuittance: json['urlQuittance'] ?? '/payments/receipt/${json['paiementId'] ?? json['id']}',
    );
  }
}