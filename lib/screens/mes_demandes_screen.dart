


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bien.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';

class DemandeLocationScreen extends StatefulWidget {
  final Bien bien;

  const DemandeLocationScreen({
    super.key,
    required this.bien,
  });

  @override
  State<DemandeLocationScreen> createState() => _DemandeLocationScreenState();
}

class _DemandeLocationScreenState extends State<DemandeLocationScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dureeController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Variables d'état
  bool _isLoading = false;
  String _error = '';
  String _success = '';

  // Variables pour la date
  DateTime? _selectedDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Initialiser la date par défaut (demain)
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _dateDebutController.text = _dateFormat.format(_selectedDate!);
    _dureeController.text = '12'; // Durée par défaut: 12 mois
  }

  @override
  void dispose() {
    _dateDebutController.dispose();
    _dureeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Fonction pour sélectionner la date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // 5 ans max
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.blue600,
              onPrimary: Colors.white,
              onSurface: AppColors.gray800,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue600,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateDebutController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _submitDemande() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
      _success = '';
    });

    try {
      // Préparer les données de la demande comme Map
      final Map<String, dynamic> demandeData = {
        'bienId': widget.bien.id,
        'dateDebut': _selectedDate!.toIso8601String().split('T')[0], // Format YYYY-MM-DD
        'dureeContrat': int.parse(_dureeController.text),
      };

      // Ajouter le message seulement s'il n'est pas vide
      if (_messageController.text.isNotEmpty) {
        demandeData['message'] = _messageController.text;
      }

      print('📤 Données à envoyer:');
      print('  bienId: ${demandeData['bienId']} (type: ${demandeData['bienId'].runtimeType})');
      print('  dateDebut: ${demandeData['dateDebut']}');
      print('  dureeContrat: ${demandeData['dureeContrat']}');
      if (demandeData.containsKey('message')) {
        print('  message: ${demandeData['message']}');
      }

      // Appeler l'API avec le Map
      final response = await _apiService.post(
        '/api/v1/demandes-location',
        body: demandeData, // Envoyer directement le Map
      );

      if (response.statusCode == 201) {
        print('✅ Demande créée avec succès');

        setState(() {
          _success = 'Votre demande a été envoyée avec succès!';
          _isLoading = false;
        });

        // Attendre 2 secondes puis retourner
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context, true);

      } else {
        print('❌ Erreur serveur: ${response.statusCode}');
        print('❌ Réponse: ${response.body}');

        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ??
              errorBody['error'] ??
              'Erreur serveur: ${response.statusCode}';
        } catch (_) {
          errorMessage = 'Erreur serveur: ${response.statusCode}';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi: $e');
      setState(() {
        _error = 'Erreur: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  // Fonction pour valider la durée
  String? _validateDuree(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une durée';
    }

    final duree = int.tryParse(value);
    if (duree == null) {
      return 'Veuillez entrer un nombre valide';
    }

    if (duree < 1) {
      return 'La durée doit être d\'au moins 1 mois';
    }

    if (duree > 120) {
      return 'La durée ne peut pas dépasser 120 mois (10 ans)';
    }

    return null;
  }

  // Fonction pour valider la date
  String? _validateDate(String? value) {
    if (_selectedDate == null) {
      return 'Veuillez sélectionner une date';
    }

    if (_selectedDate!.isBefore(DateTime.now())) {
      return 'La date doit être dans le futur';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information sur le bien
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue600),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bien concerné',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.blue600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.bien.typeBien} - ${widget.bien.ville}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.bien.adresse,
                    style: const TextStyle(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip('Réf: ${widget.bien.reference}'),
                      const SizedBox(width: 8),
                      _buildInfoChip('Loyer: ${widget.bien.loyerMensuel} DH'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Formulaire
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formulaire de demande',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Champ Date de début
                  TextFormField(
                    controller: _dateDebutController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date de début souhaitée',
                      hintText: 'Sélectionnez une date',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month_rounded),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    validator: _validateDate,
                    onTap: () => _selectDate(context),
                  ),

                  const SizedBox(height: 16),

                  // Champ Durée du contrat
                  TextFormField(
                    controller: _dureeController,
                    decoration: InputDecoration(
                      labelText: 'Durée du contrat (mois)',
                      hintText: 'Ex: 12 pour 1 an',
                      prefixIcon: const Icon(Icons.date_range_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateDuree,
                  ),

                  const SizedBox(height: 16),

                  // Champ Message (optionnel)
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Message (optionnel)',
                      hintText: 'Ajoutez un message pour le propriétaire...',
                      prefixIcon: const Icon(Icons.message_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 4,
                    maxLength: 2000,
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Vous pouvez ajouter des informations supplémentaires concernant votre demande.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Messages d'erreur/succès
                  if (_error.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.red50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.red600),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.red600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error,
                              style: TextStyle(color: AppColors.red600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_success.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.green600),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.green600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _success,
                              style: TextStyle(color: AppColors.green600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_error.isEmpty && _success.isEmpty)
                    const SizedBox(height: 24),

                  // Bouton de soumission
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitDemande,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Envoyer la demande',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Informations supplémentaires
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: AppColors.blue600,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Informations importantes',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.blue600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Votre demande sera examinée par l\'administrateur.\n'
                              '• Vous serez notifié par email de la réponse.\n'
                              '• La durée minimale est de 1 mois.\n'
                              '• Le loyer mensuel est de ${widget.bien.loyerMensuel} DH.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blue600,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.blue600,
        ),
      ),
    );
  }
}