class Bien {
  final int id;
  final String reference;
  final String typeBien;
  final String adresse;
  final String ville;
  final String codePostal;
  final double loyerMensuel;
  final double charges;
  final double caution;
  final String statut;
  final List<String> photos;

  Bien({
    required this.id,
    required this.reference,
    required this.typeBien,
    required this.adresse,
    required this.ville,
    required this.codePostal,
    required this.loyerMensuel,
    required this.charges,
    required this.caution,
    required this.statut,
    required this.photos,
  });

  factory Bien.fromJson(Map<String, dynamic> json) {
    return Bien(
      id: json['id'],
      reference: json['reference'],
      typeBien: json['typeBien'],
      adresse: json['adresse'],
      ville: json['ville'],
      codePostal: json['codePostal'],
      loyerMensuel: double.parse(json['loyerMensuel'].toString()),
      charges: double.parse(json['charges'].toString()),
      caution: double.parse(json['caution'].toString()),
      statut: json['statut'],
      photos: List<String>.from(json['photos'] ?? []),
    );
  }
}
