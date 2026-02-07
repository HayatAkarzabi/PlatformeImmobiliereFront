// lib/screens/proprietaire/nouveau_bien_screen.dart - VERSION FINALE QUI FONCTIONNE
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../models/bien.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_color.dart';

class NouveauBienScreen extends StatefulWidget {
  const NouveauBienScreen({super.key});

  @override
  State<NouveauBienScreen> createState() => _NouveauBienScreenState();
}

class _NouveauBienScreenState extends State<NouveauBienScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  final Map<String, dynamic> _bienData = {
    'typeBien': 'APPARTEMENT',
    'ville': '',
    'adresse': '',
    'codePostal': '',  // OBLIGATOIRE
    'surface': '',
    'nombrePieces': '1',  // Optionnel
    'nombreChambres': '1',  // Optionnel
    'nombreSallesBain': '1',  // Optionnel
    'loyerMensuel': '',
    'charges': '0',
    'caution': '0',
    'description': '',
    'meuble': false,
    'balcon': false,
    'parking': false,
    'ascenseur': false,
  };
  List<XFile> _imageFiles = [];
  bool _loading = false;

  final List<String> _types = ['APPARTEMENT', 'MAISON', 'VILLA', 'STUDIO'];

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (images != null && images.isNotEmpty) {
        setState(() => _imageFiles.addAll(images));
      }
    } catch (e) {
      print('Erreur sélection images: $e');
    }
  }

  // CORRECTION : Envoyer TOUJOURS avec multipart/form-data
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      final user = await _authService.getProfile();
      final token = await _authService.getToken();

      if (token == null) throw Exception('Non authentifié');

      // Nettoyer les nombres
      double parseDouble(String value) {
        try {
          return double.parse(value.replaceAll(',', '.'));
        } catch (e) {
          return 0.0;
        }
      }

      // 1. Créer le JSON comme requis
      // Dans la méthode _submitForm() ou _sendMultipartRequest()
      final bienJson = jsonEncode({
        'typeBien': _bienData['typeBien'],
        'ville': _bienData['ville'],
        'adresse': _bienData['adresse'],
        'codePostal': '20000',  // AJOUTEZ CETTE LIGNE - utilisez une valeur appropriée
        'surface': parseDouble(_bienData['surface']),
        'loyerMensuel': parseDouble(_bienData['loyerMensuel']),
        'charges': parseDouble(_bienData['charges']),
        'caution': parseDouble(_bienData['caution']),
        'description': _bienData['description'],
        'proprietaireId': user.id,
        'reference': 'REF-${DateTime.now().millisecondsSinceEpoch}',
        'statut': 'DISPONIBLE',  // CHANGÉ de EN_ATTENTE à DISPONIBLE
        'statutValidation': 'EN_ATTENTE',
        'meuble': _bienData['meuble'],
        'balcon': _bienData['balcon'],
        'parking': _bienData['parking'],
        'ascenseur': _bienData['ascenseur'],
        'nombrePieces': null,
        'nombreChambres': null,
        'nombreSallesBain': null,
      });

      print('📦 JSON créé: $bienJson');

      // 2. Utiliser une requête multipart CUSTOM pour le web
      final response = await _sendMultipartRequest(
        bienJson: bienJson,
        imageFiles: _imageFiles,
        token: token!,
      );

      print('📥 Réponse: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Bien créé avec succès!')),
        );
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 ERREUR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // SOLUTION : Méthode pour envoyer la requête multipart CORRECTEMENT
  Future<http.Response> _sendMultipartRequest({
    required String bienJson,
    required List<XFile> imageFiles,
    required String token,
  }) async {
    try {
      final url = Uri.parse('http://localhost:8000/api/v1/biens');
      print('🌐 Envoi multipart à: $url');

      var request = http.MultipartRequest('POST', url);

      // IMPORTANT: Pas de Content-Type header pour multipart
      request.headers['Authorization'] = 'Bearer $token';

      // Ajouter le champ 'bien' avec le JSON
      request.fields['bien'] = bienJson;
      print('📝 Champ "bien" ajouté (${bienJson.length} caractères)');

      // Ajouter les photos OU une image vide
      if (imageFiles.isEmpty) {
        print('📸 Pas de photos - création image vide');
        // Créer une image PNG vide 1x1 pixel
        final emptyImage = _createEmptyPngImage();
        final multipartFile = http.MultipartFile.fromBytes(
          'photos',
          emptyImage,
          filename: 'empty.png',
        );
        request.files.add(multipartFile);
        print('📸 Image vide ajoutée');
      } else {
        print('📸 Ajout de ${imageFiles.length} photo(s)');
        for (int i = 0; i < imageFiles.length; i++) {
          final file = imageFiles[i];
          final bytes = await file.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            'photos',
            bytes,
            filename: 'photo_$i.jpg',
          );
          request.files.add(multipartFile);
          print('📸 Photo $i ajoutée: ${bytes.length} bytes');
        }
      }

      // Envoyer la requête
      print('📤 Envoi de la requête...');
      final streamedResponse = await request.send();

      // Convertir la réponse
      final response = await http.Response.fromStream(streamedResponse);
      print('✅ Réponse reçue: ${response.statusCode}');

      return response;
    } catch (e) {
      print('❌ Erreur multipart: $e');
      rethrow;
    }
  }

  // Créer une image PNG vide 1x1 pixel (transparente)
  Uint8List _createEmptyPngImage() {
    return Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
      0x49, 0x48, 0x44, 0x52, // "IHDR"
      0x00, 0x00, 0x00, 0x01, // width = 1
      0x00, 0x00, 0x00, 0x01, // height = 1
      0x08, 0x02, 0x00, 0x00, 0x00, // bit depth = 8, color type = 2
      0x00, 0x00, 0x00, 0x00, // compression = 0
      0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82 // IEND
    ]);
  }

  // VERSION SIMPLE POUR TESTER : Sans photos du tout
  Future<void> _testSimple() async {
    setState(() => _loading = true);

    try {
      final user = await _authService.getProfile();
      final token = await _authService.getToken();

      if (token == null) throw Exception('Non authentifié');

      // JSON très simple
      final bienJson = jsonEncode({
        'typeBien': 'APPARTEMENT',
        'ville': 'TestVille',
        'adresse': 'Test Adresse',
        'surface': 75.0,
        'loyerMensuel': 3500.0,
        'charges': 0.0,
        'caution': 0.0,
        'description': 'Description test',
        'proprietaireId': user.id,
        'statut': 'EN_ATTENTE',
        'meuble': false,
        'balcon': false,
        'parking': false,
        'ascenseur': false,
      });

      print('🧪 TEST SIMPLE');
      print('📦 JSON: $bienJson');

      // Appeler votre ApiService.postMultipart
      final response = await _apiService.postMultipart(
        '/api/v1/biens',
        {},
        fields: {'bien': bienJson},
        files: _imageFiles.isEmpty
            ? {'empty.png': 'photos'}  // Image fictive
            : _convertToFileMap(),
      );

      print('📥 Réponse: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Test réussi!')),
        );
      }
    } catch (e) {
      print('💥 ERREUR: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Map<String, String> _convertToFileMap() {
    final map = <String, String>{};
    for (final file in _imageFiles) {
      map[file.path] = 'photos';
    }
    return map;
  }

  // TEST DIRECT AVEC HTTP
  Future<void> _testDirectHttp() async {
    setState(() => _loading = true);

    try {
      final user = await _authService.getProfile();
      final token = await _authService.getToken();

      print('🔑 Token: ${token?.substring(0, 20)}...');

      // 1. Créer une requête multipart
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:8000/api/v1/biens')
      );

      // 2. Ajouter le token
      request.headers['Authorization'] = 'Bearer $token';

      // 3. Ajouter le JSON dans le champ 'bien'
      final bienJson = jsonEncode({
        'typeBien': _bienData['typeBien'],  // APPARTEMENT, MAISON, etc.
        'ville': _bienData['ville'],
        'adresse': _bienData['adresse'],
        'codePostal': _bienData['codePostal'],  // Format: 5 chiffres, ex: "20000"
        'surface': (_bienData['surface']),
        'loyerMensuel': (_bienData['loyerMensuel']),
        'charges': (_bienData['charges']),
        'caution': (_bienData['caution']),
        'description': _bienData['description'],
        'proprietaireId': user.id,  // Long, pas int
        'statut': 'DISPONIBLE',  // UNIQUEMENT statut, PAS statutValidation
        'meuble': _bienData['meuble'],
        'balcon': _bienData['balcon'],
        'parking': _bienData['parking'],
        'ascenseur': _bienData['ascenseur'],
        // Optionnel - selon votre formulaire :
        'nombrePieces': int.tryParse(_bienData['nombrePieces'] ?? '') ?? 1,
        'nombreChambres': int.tryParse(_bienData['nombreChambres'] ?? '') ?? 1,
        'nombreSallesBain': int.tryParse(_bienData['nombreSallesBain'] ?? '') ?? 1,
        'dateAcquisition': null,  // Ou une date si vous avez ce champ
      });

      request.fields['bien'] = bienJson;
      print('📦 JSON ajouté: ${bienJson.length} caractères');

      // 4. Créer une image de test (1x1 pixel transparent)
      final pngBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
        0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
        0x54, 0x08, 0xD7, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
        0x00, 0x05, 0xFE, 0x02, 0xFE, 0xDC, 0xCC, 0x59,
        0xE7, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
        0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      final multipartFile = http.MultipartFile.fromBytes(
        'photos',
        pngBytes,
        filename: 'test.png',
      );
      request.files.add(multipartFile);
      print('📸 Image test ajoutée');

      // 5. Envoyer
      print('📤 Envoi de la requête...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Réponse: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Test HTTP direct réussi!')),
        );
      }
    } catch (e) {
      print('💥 ERREUR HTTP: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildImagePreview() {
    if (_imageFiles.isEmpty) {
      return Column(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text('Aucune photo (une image vide sera envoyée)'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '⚠️ Une image vide sera automatiquement envoyée',
            style: TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageFiles.length,
            itemBuilder: (context, index) {
              return FutureBuilder<Uint8List>(
                future: _imageFiles[index].readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 150,
                      height: 150,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        snapshot.data!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('${_imageFiles.length} photo(s)'),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _imageFiles.clear()),
              child: const Text('Effacer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String field,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(

      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ce champ est requis';
        if (keyboardType == TextInputType.number) {
          final cleaned = value.replaceAll(',', '.');
          if (double.tryParse(cleaned) == null) return 'Nombre invalide';
        }
        return null;
      },
      onSaved: (value) => _bienData[field] = value?.trim() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Bien'),
        actions: [
          if (_loading) const CircularProgressIndicator(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Section photos
              const Text('Photos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildImagePreview(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Ajouter des photos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 24),

              // Type de bien
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type de bien',
                  border: OutlineInputBorder(),
                ),
                value: _bienData['typeBien'],
                items: _types.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toLowerCase().replaceFirst(type[0].toLowerCase(), type[0])),
                )).toList(),
                onChanged: (value) => setState(() => _bienData['typeBien'] = value!),
              ),

              const SizedBox(height: 16),
              _buildTextField(label: 'Ville', field: 'ville'),
              const SizedBox(height: 16),
              _buildTextField(label: 'Adresse', field: 'adresse', maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField(label: 'Code Postal', field: 'codePostal', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(label: 'Surface (m²)', field: 'surface', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(label: 'Loyer mensuel (DH)', field: 'loyerMensuel', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(label: 'Charges (DH)', field: 'charges', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(label: 'Caution (DH)', field: 'caution', keyboardType: TextInputType.number),

              const SizedBox(height: 16),
              _buildTextField(label: 'Description', field: 'description', maxLines: 4),

              const SizedBox(height: 32),

              // Bouton principal
              ElevatedButton(
                onPressed: _loading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Publier le bien',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              // Boutons de test
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Tests:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),

              OutlinedButton(
                onPressed: _loading ? null : _testSimple,
                child: const Text('Test simple avec ApiService'),
              ),

              const SizedBox(height: 8),

              OutlinedButton(
                onPressed: _loading ? null : _testDirectHttp,
                child: const Text('Test HTTP direct avec image vide'),
              ),

              // Instructions
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📋 Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('1. Remplissez tous les champs'),
                    Text('2. Utilisez des points (.) pas des virgules pour les nombres'),
                    Text('3. Cliquez sur "Publier le bien"'),
                    Text('4. Si erreur, essayez les boutons de test'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}