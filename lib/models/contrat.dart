class Contrat {
  final int id;
  final String reference;
  final String dateDebut;
  final String dateFin;
  final String? dateSignature;
  final double? loyerMensuel;
  final double? charges;
  final double? caution;
  final String statut;
  final String? typeContrat;
  final int? dureeContrat;
  final int? jourPaiement;
  final String? bienAdresse;
  final String? bienVille;

  Contrat({
    required this.id,
    required this.reference,
    required this.dateDebut,
    required this.dateFin,
    required this.loyerMensuel,
    required this.charges,
    required this.caution,
    required this.jourPaiement,
    required this.typeContrat,
    required this.dureeContrat,
    required this.statut,
    this.dateSignature, this.bienAdresse, this.bienVille,

  });

  factory Contrat.fromJson(Map<String, dynamic> json) {
    return Contrat(
      id: json['id'],
      reference: json['reference'],
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      loyerMensuel: double.parse(json['loyerMensuel'].toString()),
      charges: double.parse(json['charges'].toString()),
      caution: double.parse(json['caution'].toString()),
      jourPaiement: json['jourPaiement'],
      typeContrat: json['typeContrat'],
      dureeContrat: json['dureeContrat'],
      statut: json['statut'],
      dateSignature: json['dateSignature'],

    );
  }
}
