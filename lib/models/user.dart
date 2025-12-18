class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String adresse;
  final String type;
  final String? token;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.adresse,
    required this.type,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Adapté pour votre table "personne"
    return User(
      id: json['id'] ?? json['ID_Personne'],
      firstName: json['firstName'] ?? json['Nom'] ?? '',
      lastName: json['lastName'] ?? json['Prenom'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      phone: json['phone'] ?? json['Telephone'] ?? '',
      adresse: json['adresse'] ?? json['Adresse'] ?? '',
      type: json['type'] ?? json['Type'] ?? 'LOCATAIRE',
      token: json['token'],
    );
  }

  // Pour la réponse d'authentification de votre backend
  factory User.fromAuthResponse(Map<String, dynamic> json) {
    return User(
      id: json['user']?['id'] ?? json['id'] ?? json['ID_Personne'],
      firstName: json['user']?['firstName'] ?? json['Nom'] ?? '',
      lastName: json['user']?['lastName'] ?? json['Prenom'] ?? '',
      email: json['user']?['email'] ?? json['Email'] ?? '',
      phone: json['user']?['phone'] ?? json['Telephone'] ?? '',
      adresse: json['user']?['adresse'] ?? json['Adresse'] ?? '',
      type: json['user']?['type'] ?? json['Type'] ?? 'LOCATAIRE',
      token: json['token'] ?? json['access_token'],
    );
  }

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() => {
    'id': id,
    'Nom': firstName,
    'Prenom': lastName,
    'Email': email,
    'Telephone': phone,
    'Adresse': adresse,
    'Type': type,
  };
}