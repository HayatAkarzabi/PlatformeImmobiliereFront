// lib/screens/create_reclamation_screen.dart
import 'package:flutter/material.dart';
import '../models/contrat.dart';
import '../services/reclamation_service.dart';

class CreateReclamationScreen extends StatefulWidget {
  final Contrat contrat;

  const CreateReclamationScreen({
    super.key,
    required this.contrat,
  });

  @override
  State<CreateReclamationScreen> createState() => _CreateReclamationScreenState();
}

class _CreateReclamationScreenState extends State<CreateReclamationScreen> {
  final ReclamationService _service = ReclamationService();
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();

  // CORRECTION ICI : Utilise les valeurs EXACTES de l'enum backend
  String _selectedType = 'PLOMBERIE'; // PLOMBERIE, ELECTRICITE, CHAUFFAGE, CLIMATISATION, SERRURERIE, AUTRE
  String _selectedPriorite = 'MOYENNE'; // Doit correspondre à l'enum PrioriteReclamation
  bool _isLoading = false;

  // Liste des types disponibles (exactement comme l'enum backend)
  final List<Map<String, dynamic>> _typesReclamation = [
    {'value': 'PLOMBERIE', 'label': 'Plomberie', 'icon': Icons.water_damage, 'color': Colors.blue},
    {'value': 'ELECTRICITE', 'label': 'Électricité', 'icon': Icons.electrical_services, 'color': Colors.amber},
    {'value': 'CHAUFFAGE', 'label': 'Chauffage', 'icon': Icons.thermostat, 'color': Colors.orange},
    {'value': 'CLIMATISATION', 'label': 'Climatisation', 'icon': Icons.ac_unit, 'color': Colors.cyan},
    {'value': 'SERRURERIE', 'label': 'Serrurerie', 'icon': Icons.lock, 'color': Colors.brown},
    {'value': 'AUTRE', 'label': 'Autre', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  // Dans _CreateReclamationScreenState, changez la liste des priorités :
  final List<Map<String, dynamic>> _priorites = [
    {'value': 'BASSE', 'label': 'Basse', 'color': Colors.green},       // Avant: 'FAIBLE'
    {'value': 'MOYENNE', 'label': 'Moyenne', 'color': Colors.orange},
    {'value': 'HAUTE', 'label': 'Haute', 'color': Colors.red},         // Avant: 'ELEVEE'
    {'value': 'URGENTE', 'label': 'Urgente', 'color': Colors.red[900]},
  ];


  @override
  void initState() {
    super.initState();
    // Initialiser avec la première priorité disponible
    if (_priorites.isNotEmpty) {
      _selectedPriorite = _priorites[1]['value']; // Moyenne par défaut
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // CORRECTION ICI : Envoie les valeurs EXACTES attendues par le backend
      await _service.creerReclamation(
        titre: _titreController.text,
        description: _descriptionController.text,
        type: _selectedType, // Ex: 'PLOMBERIE' (pas 'NORMAL')
        priorite: _selectedPriorite, // Ex: 'ELEVEE' (pas 'HAUTE')
        contratId: widget.contrat.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réclamation envoyée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Réclamation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info contrat
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contrat concerné',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text('Référence: ${widget.contrat.reference}'),
                      Text('Adresse: ${widget.contrat.bienAdresse ?? 'Non spécifiée'}'),
                      Text('Statut: ${widget.contrat.statut}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Titre
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la réclamation *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                  hintText: 'Ex: Fuite d\'eau dans la salle de bain',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est requis';
                  }
                  if (value.length < 5) {
                    return 'Le titre doit faire au moins 5 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Type de problème - NOUVELLE VERSION
              const Text(
                'Type de problème *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _typesReclamation.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return ChoiceChip(
                    avatar: Icon(
                      type['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : type['color'] as Color,
                    ),
                    label: Text(
                      type['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedType = type['value'] as String);
                    },
                    selectedColor: type['color'] as Color,
                    backgroundColor: (type['color'] as Color).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? type['color'] as Color : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Priorité - NOUVELLE VERSION
              const Text(
                'Priorité *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _priorites.map((priorite) {
                  final isSelected = _selectedPriorite == priorite['value'];
                  return ChoiceChip(
                    label: Text(
                      priorite['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedPriorite = priorite['value'] as String);
                    },
                    selectedColor: priorite['color'] as Color,
                    backgroundColor: (priorite['color'] as Color).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? priorite['color'] as Color : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description détaillée *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  hintText: 'Décrivez le problème en détail...',
                ),
                maxLines: 5,
                minLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La description est requise';
                  }
                  if (value.length < 10) {
                    return 'La description doit faire au moins 10 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),
              Text(
                'Décrivez précisément le problème, l\'emplacement, et depuis quand il existe.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 30),

              // Bouton d'envoi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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
                    'Envoyer la réclamation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Information sur le traitement
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Votre réclamation sera traitée dans les plus brefs délais. '
                            'Vous serez notifié de son avancement.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
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