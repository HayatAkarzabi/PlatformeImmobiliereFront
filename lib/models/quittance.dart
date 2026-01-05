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
  final DateTime? dateGeneration;

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
    this.dateGeneration,
  });

  factory Quittance.fromJson(Map<String, dynamic> json) {
    return Quittance(
      paiementId: json['paiementId']?.toInt() ?? json['paymentId'],
      reference: json['reference'] ?? '',
      datePaiement: DateTime.parse(json['datePaiement'] ?? json['date_paiement']),
      montantTotal: (json['montantTotal'] ?? 0).toDouble(),
      periode: json['periode'] ?? '',
      bienAdresse: json['bienAdresse'] ?? json['bien_adresse'] ?? '',
      nomProprietaire: json['nomProprietaire'] ?? json['nom_proprietaire'] ?? '',
      nomLocataire: json['nomLocataire'] ?? json['nom_locataire'] ?? '',
      urlQuittance: json['urlQuittance'] ?? json['url_quittance'] ?? '',
      dateGeneration: json['dateGeneration'] != null
          ? DateTime.parse(json['dateGeneration'] ?? json['date_generation'])
          : null,
    );
  }

  String get periodeCourte {
    // Format: "Décembre 2024" au lieu de "01/12/2024 au 31/12/2024"
    if (periode.contains('au')) {
      return periode.split('au').first.trim();
    }
    return periode;
  }
}