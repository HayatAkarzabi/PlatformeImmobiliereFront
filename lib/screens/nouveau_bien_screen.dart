// screens/ajouter_bien_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bien.dart';

class AjouterBienScreen extends StatefulWidget {
  final String token;

  const AjouterBienScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AjouterBienScreenState createState() => _AjouterBienScreenState();
}

class _AjouterBienScreenState extends State<AjouterBienScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();

  // Contrôleurs
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();
  final TextEditingController _surfaceController = TextEditingController();
  final TextEditingController _piecesController = TextEditingController(text: '1');
  final TextEditingController _chambresController = TextEditingController(text: '1');
  final TextEditingController _sallesBainController = TextEditingController(text: '1');
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _loyerController = TextEditingController();
  final TextEditingController _chargesController = TextEditingController(text: '0');
  final TextEditingController _cautionController = TextEditingController(text: '0');

  // Valeurs par défaut
  String _selectedType = 'APPARTEMENT';
  String _selectedStatut = 'DISPONIBLE';
  bool _meuble = false;
  bool _balcon = false;
  bool _parking = false;
  bool _ascenseur = false;

  bool _isLoading = false;

  final List<String> _types = [
    'APPARTEMENT',
    'MAISON',
    'VILLA',
    'STUDIO',
    'CHAMBRE',
    'COMMERCE'
  ];

  final List<String> _statuts = [
    'DISPONIBLE',
    'LOUE',
    'EN_MAINTENANCE',
    'INDISPONIBLE'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un bien'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type et Statut
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type de bien',
                        border: OutlineInputBorder(),
                      ),
                      items: _types.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatut,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: _statuts.map((statut) {
                        return DropdownMenuItem<String>(
                          value: statut,
                          child: Text(statut),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatut = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Adresse
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'adresse est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Ville et Code postal
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _villeController,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La ville est obligatoire';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _codePostalController,
                      decoration: const InputDecoration(
                        labelText: 'Code postal',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le code postal est obligatoire';
                        }
                        if (value.length != 5) {
                          return '5 chiffres requis';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Surface
              TextFormField(
                controller: _surfaceController,
                decoration: const InputDecoration(
                  labelText: 'Surface (m²)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La surface est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Pièces, Chambres, Salles de bain
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _piecesController,
                      decoration: const InputDecoration(
                        labelText: 'Pièces',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _chambresController,
                      decoration: const InputDecoration(
                        labelText: 'Chambres',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _sallesBainController,
                      decoration: const InputDecoration(
                        labelText: 'Salles de bain',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Loyer, Charges, Caution
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _loyerController,
                      decoration: const InputDecoration(
                        labelText: 'Loyer (€)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le loyer est obligatoire';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _chargesController,
                      decoration: const InputDecoration(
                        labelText: 'Charges (€)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _cautionController,
                      decoration: const InputDecoration(
                        labelText: 'Caution (€)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Équipements
              const Text('Équipements:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Meublé'),
                    selected: _meuble,
                    onSelected: (bool value) {
                      setState(() {
                        _meuble = value;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Balcon'),
                    selected: _balcon,
                    onSelected: (bool value) {
                      setState(() {
                        _balcon = value;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Parking'),
                    selected: _parking,
                    onSelected: (bool value) {
                      setState(() {
                        _parking = value;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Ascenseur'),
                    selected: _ascenseur,
                    onSelected: (bool value) {
                      setState(() {
                        _ascenseur = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Photos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Photos:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${_selectedPhotos.length}/10'),
                ],
              ),
              const SizedBox(height: 8),

              // Boutons pour ajouter des photos
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galerie'),
                    ),
                  ),
                ],
              ),

              // Aperçu des photos
              if (_selectedPhotos.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedPhotos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Image.file(
                              File(_selectedPhotos[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removePhoto(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Bouton d'enregistrement
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer le bien'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (_selectedPhotos.length < 10) {
          setState(() {
            _selectedPhotos.add(pickedFile);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 10 photos autorisées')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Préparer les données
      final bienData = {
        'typeBien': _selectedType,
        'adresse': _adresseController.text,
        'ville': _villeController.text,
        'codePostal': _codePostalController.text,
        'surface': double.parse(_surfaceController.text),
        'nombrePieces': int.parse(_piecesController.text),
        'nombreChambres': int.parse(_chambresController.text),
        'nombreSallesBain': int.parse(_sallesBainController.text),
        'description': _descriptionController.text,
        'loyerMensuel': double.parse(_loyerController.text),
        'charges': double.parse(_chargesController.text),
        'caution': double.parse(_cautionController.text),
        'statut': _selectedStatut,
        'meuble': _meuble,
        'balcon': _balcon,
        'parking': _parking,
        'ascenseur': _ascenseur,
        'proprietaireId': 1, // À remplacer par l'ID réel
      };

      // Si des photos sont sélectionnées, utiliser une requête multipart
      if (_selectedPhotos.isNotEmpty) {
        await _createBienWithPhotos(bienData);
      } else {
        await _createBienWithoutPhotos(bienData);
      }

      // Succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bien créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      // Retourner à l'écran précédent
      Navigator.pop(context, true);

    } catch (e) {
      // Erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createBienWithPhotos(Map<String, dynamic> bienData) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/api/v1/biens')
    );

    // Ajouter le token d'authentification
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    // Ajouter les données JSON
    request.fields['bien'] = json.encode(bienData);

    // Ajouter les photos
    for (var photo in _selectedPhotos) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photos',
          photo.path,
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Erreur ${response.statusCode}');
    }
  }

  Future<void> _createBienWithoutPhotos(Map<String, dynamic> bienData) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/v1/biens'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: json.encode(bienData),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }

  @override
  void dispose() {
    _adresseController.dispose();
    _villeController.dispose();
    _codePostalController.dispose();
    _surfaceController.dispose();
    _piecesController.dispose();
    _chambresController.dispose();
    _sallesBainController.dispose();
    _descriptionController.dispose();
    _loyerController.dispose();
    _chargesController.dispose();
    _cautionController.dispose();
    super.dispose();
  }
}