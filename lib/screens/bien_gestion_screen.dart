// lib/screens/admin/biens_gestion_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/bien.dart';
import '../../models/bien_validation.dart';
import '../../services/bien_service.dart';

// ========== VOUS MANQUE CETTE CLASSE ==========
class BiensGestionScreen extends StatefulWidget {
  const BiensGestionScreen({super.key});

  @override
  State<BiensGestionScreen> createState() => _BiensGestionScreenState();
}
// =============================================

class _BiensGestionScreenState extends State<BiensGestionScreen> {
  final BienService _bienService = BienService();
  List<Bien> _biensEnAttente = [];
  List<Bien> _biensValides = [];
  List<Bien> _biensRejetes = [];
  bool _isLoading = true;
  String _error = '';
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadBiens();
  }

  Future<void> _loadBiens() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final allBiens = await _bienService.getAllBiens();

      setState(() {
        _biensEnAttente = allBiens.where((b) => b.statutValidation == 'EN_ATTENTE').toList();
        _biensValides = allBiens.where((b) => b.statutValidation == 'VALIDE').toList();
        _biensRejetes = allBiens.where((b) => b.statutValidation == 'REJETE').toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement biens: $e');
      setState(() {
        _error = 'Impossible de charger les biens';
        _isLoading = false;
      });
    }
  }

  Future<void> _validerBien(Bien bien, String statut, String? commentaire) async {
    try {
      final validationDto = BienValidationDto(
        statutValidation: statut,
        commentaire: commentaire,
      );

      await _bienService.validerBien(bien.id, validationDto);

      await _loadBiens();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            statut == 'VALIDE'
                ? 'Bien validé avec succès'
                : 'Bien rejeté avec succès',
          ),
          backgroundColor: statut == 'VALIDE' ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      print('❌ Erreur validation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBienCard(Bien bien) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bien.reference,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTypeBien(bien.typeBien),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(bien.statutValidation).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(bien.statutValidation).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _formatStatus(bien.statutValidation),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(bien.statutValidation),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${bien.ville}, ${bien.adresse}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.monetization_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${bien.loyerMensuel.toStringAsFixed(0)} DH/mois',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(Icons.zoom_out_map_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${bien.surface}m²',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (bien.statutValidation == 'EN_ATTENTE') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showValidationDialog(bien, 'VALIDE'),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Valider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejetDialog(bien),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Rejeter'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (bien.statutValidation == 'REJETE' && bien.dateValidation != null) ...[
              Text(
                'Rejeté le ${_formatDate(bien.dateValidation!)}',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ] else if (bien.statutValidation == 'VALIDE' && bien.dateValidation != null) ...[
              Text(
                'Validé le ${_formatDate(bien.dateValidation!)}',
                style: TextStyle(color: Colors.green.shade600, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showValidationDialog(Bien bien, String statut) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          statut == 'VALIDE'
              ? 'Valider ce bien ?'
              : 'Rejeter ce bien ?',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Référence: ${bien.reference}'),
            Text('Type: ${_formatTypeBien(bien.typeBien)}'),
            Text('Ville: ${bien.ville}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _validerBien(bien, statut, null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: statut == 'VALIDE' ? Colors.green : Colors.orange,
            ),
            child: Text(statut == 'VALIDE' ? 'Valider' : 'Rejeter'),
          ),
        ],
      ),
    );
  }

  void _showRejetDialog(Bien bien) {
    TextEditingController commentaireController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter ce bien'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Veuillez indiquer le motif du rejet:'),
            const SizedBox(height: 12),
            TextField(
              controller: commentaireController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Motif du rejet...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentaireController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez indiquer un motif'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _validerBien(bien, 'REJETE', commentaireController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Confirmer le rejet'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, int count) {
    return FilterChip(
      label: Text('$label ($count)'),
      selected: _selectedFilter == index,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = index;
        });
      },
      selectedColor: Colors.blueGrey.shade100,
      checkmarkColor: Colors.blueGrey,
    );
  }

  List<Bien> _getCurrentList() {
    switch (_selectedFilter) {
      case 0: return _biensEnAttente;
      case 1: return _biensValides;
      case 2: return _biensRejetes;
      default: return _biensEnAttente;
    }
  }

  String _getCurrentTitle() {
    switch (_selectedFilter) {
      case 0: return 'Biens en attente (${_biensEnAttente.length})';
      case 1: return 'Biens validés (${_biensValides.length})';
      case 2: return 'Biens rejetés (${_biensRejetes.length})';
      default: return 'Biens en attente';
    }
  }

  String _formatTypeBien(String type) {
    switch (type) {
      case 'APPARTEMENT': return 'Appartement';
      case 'MAISON': return 'Maison';
      case 'VILLA': return 'Villa';
      case 'STUDIO': return 'Studio';
      default: return type;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'EN_ATTENTE': return 'En attente';
      case 'VALIDE': return 'Validé';
      case 'REJETE': return 'Rejeté';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EN_ATTENTE': return Colors.orange;
      case 'VALIDE': return Colors.green;
      case 'REJETE': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation des biens'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBiens,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('En attente', 0, _biensEnAttente.length),
                const SizedBox(width: 8),
                _buildFilterChip('Validés', 1, _biensValides.length),
                const SizedBox(width: 8),
                _buildFilterChip('Rejetés', 2, _biensRejetes.length),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getCurrentTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                if (_selectedFilter == 0 && _biensEnAttente.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _loadBiens,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Vérifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _getCurrentList().isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedFilter == 0
                        ? Icons.check_box_outline_blank
                        : _selectedFilter == 1
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 0
                        ? 'Aucun bien en attente'
                        : _selectedFilter == 1
                        ? 'Aucun bien validé'
                        : 'Aucun bien rejeté',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadBiens,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _getCurrentList().length,
                itemBuilder: (context, index) {
                  return _buildBienCard(_getCurrentList()[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}