// lib/models/bien_validation.dart
class BienValidationDto {
  final String statutValidation; // VALIDE, REJETE
  final String? commentaire;

  BienValidationDto({
    required this.statutValidation,
    this.commentaire,
  });

  Map<String, dynamic> toJson() {
    return {
      'statutValidation': statutValidation,
      if (commentaire != null && commentaire!.isNotEmpty)
        'commentaire': commentaire,
    };
  }

  factory BienValidationDto.fromJson(Map<String, dynamic> json) {
    return BienValidationDto(
      statutValidation: json['statutValidation'],
      commentaire: json['commentaire'],
    );
  }
}