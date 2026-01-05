// class Bien {
//   final int id;
//   final String reference;
//   final String typeBien;
//   final String adresse;
//   final String ville;
//   final String codePostal;
//   final double loyerMensuel;
//   final double charges;
//   final double caution;
//   final String statut;
//   final List<String> photos;
//
//   Bien({
//     required this.id,
//     required this.reference,
//     required this.typeBien,
//     required this.adresse,
//     required this.ville,
//     required this.codePostal,
//     required this.loyerMensuel,
//     required this.charges,
//     required this.caution,
//     required this.statut,
//     required this.photos,
//   });
//
//   factory Bien.fromJson(Map<String, dynamic> json) {
//     return Bien(
//       id: json['id'],
//       reference: json['reference'],
//       typeBien: json['typeBien'],
//       adresse: json['adresse'],
//       ville: json['ville'],
//       codePostal: json['codePostal'],
//       loyerMensuel: double.parse(json['loyerMensuel'].toString()),
//       charges: double.parse(json['charges'].toString()),
//       caution: double.parse(json['caution'].toString()),
//       statut: json['statut'],
//       photos: List<String>.from(json['photos'] ?? []),
//     );
//   }
// }


// models/bien.dart
class Bien {
  final int id;
  final String reference;
  final String typeBien;
  final String adresse;
  final String ville;
  final String codePostal;
  final double surface;
  final int? nombrePieces;
  final int? nombreChambres;
  final int? nombreSallesBain;
  final String? description;
  final double loyerMensuel;
  final double charges;
  final double caution;
  final String statut;
  final String statutValidation;
  final String? motifRejet;
  final DateTime? dateAcquisition;
  final List<String> photos;
  final bool meuble;
  final bool balcon;
  final bool parking;
  final bool ascenseur;

  Bien({
    required this.id,
    required this.reference,
    required this.typeBien,
    required this.adresse,
    required this.ville,
    required this.codePostal,
    required this.surface,
    this.nombrePieces,
    this.nombreChambres,
    this.nombreSallesBain,
    this.description,
    required this.loyerMensuel,
    required this.charges,
    required this.caution,
    required this.statut,
    required this.statutValidation,
    this.motifRejet,
    this.dateAcquisition,
    required this.photos,
    required this.meuble,
    required this.balcon,
    required this.parking,
    required this.ascenseur,
  });

  factory Bien.fromJson(Map<String, dynamic> json) {
    // Convertir les BigDecimals en double
    double parseBigDecimal(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Gérer la date d'acquisition
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return null;
      }
    }

    return Bien(
      id: json['id'] as int,
      reference: json['reference'] as String? ?? '',
      typeBien: json['typeBien'] as String? ?? '',
      adresse: json['adresse'] as String? ?? '',
      ville: json['ville'] as String? ?? '',
      codePostal: json['codePostal'] as String? ?? '',
      surface: parseBigDecimal(json['surface']),
      nombrePieces: json['nombrePieces'] as int?,
      nombreChambres: json['nombreChambres'] as int?,
      nombreSallesBain: json['nombreSallesBain'] as int?,
      description: json['description'] as String?,
      loyerMensuel: parseBigDecimal(json['loyerMensuel']),
      charges: parseBigDecimal(json['charges'] ?? 0),
      caution: parseBigDecimal(json['caution'] ?? 0),
      statut: json['statut'] as String? ?? '',
      statutValidation: json['statutValidation'] as String? ?? '',
      motifRejet: json['motifRejet'] as String?,
      dateAcquisition: parseDate(json['dateAcquisition']),
      photos: List<String>.from(json['photos'] ?? []),
      meuble: json['meuble'] as bool? ?? false,
      balcon: json['balcon'] as bool? ?? false,
      parking: json['parking'] as bool? ?? false,
      ascenseur: json['ascenseur'] as bool? ?? false,
    );
  }

  // Méthode pour obtenir les équipements
  List<String> get equipements {
    final List<String> eq = [];
    if (meuble) eq.add('Meublé');
    if (balcon) eq.add('Balcon');
    if (parking) eq.add('Parking');
    if (ascenseur) eq.add('Ascenseur');
    return eq;
  }
}