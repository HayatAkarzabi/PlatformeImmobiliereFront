// lib/screens/demandes/mes_demandes_screen.dart
import 'package:flutter/material.dart';
import 'package:gestion_immobilier_front/screens/mes_demandes_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/demande_location_response.dart';
import '../../services/api_service.dart';
import '../../theme/app_color.dart';

class MesDemandesScreen extends StatefulWidget {
  const MesDemandesScreen({super.key});

  @override
  State<MesDemandesScreen> createState() => _MesDemandesScreenState();
}

class _MesDemandesScreenState extends State<MesDemandesScreen> {
  List<DemandeLocationResponse> _demandes = [];
  bool _isLoading = true;
  String _error = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  Future<void> _loadDemandes() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      print('🔄 Chargement des demandes...');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Veuillez vous connecter pour voir vos demandes';
          _isLoading = false;
        });
        return;
      }

      // CORRECTION ICI : Utilisez le bon endpoint "mes-demandes"
      // À partir de votre contrôleur Spring : @GetMapping("/mes-demandes")
      final response = await _apiService.get('/api/v1/demandes-location/mes-demandes');

      print('📡 Statut de la réponse: ${response.statusCode}');
      print('📡 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        print('📊 Nombre de demandes reçues: ${data.length}');

        setState(() {
          _demandes = data.map((json) => DemandeLocationResponse.fromJson(json)).toList();
          _isLoading = false;
        });

        print('✅ ${_demandes.length} demandes chargées avec succès');

        // Debug: Afficher les statuts des demandes
        for (var demande in _demandes) {
          print('📋 Demande: ${demande.id} - Statut: ${demande.statut}');
        }
      } else if (response.statusCode == 403) {
        setState(() {
          _error = 'Accès refusé. Vous devez être connecté en tant que locataire.';
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _error = 'Session expirée. Veuillez vous reconnecter.';
          _isLoading = false;
        });
      } else {
        print('❌ Erreur serveur: ${response.statusCode} - ${response.body}');
        setState(() {
          _error = 'Erreur serveur (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Exception lors du chargement: $e');
      setState(() {
        _error = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildStatutChip(String statut) {
    Color chipColor;
    String statutLabel;

    switch (statut.toLowerCase()) {
      case 'en_attente':
      case 'en attente':
        chipColor = Colors.orange;
        statutLabel = 'En attente';
        break;
      case 'acceptee':
      case 'accepté':
        chipColor = Colors.green;
        statutLabel = 'Acceptée';
        break;
      case 'refusee':
      case 'refusé':
        chipColor = Colors.red;
        statutLabel = 'Refusée';
        break;
      case 'annulee':
      case 'annulé':
        chipColor = Colors.grey;
        statutLabel = 'Annulée';
        break;
      default:
        chipColor = Colors.blue;
        statutLabel = statut;
    }

    return Chip(
      label: Text(
        statutLabel,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non défini';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes demandes de location'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDemandes,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Pour créer une nouvelle demande
          // Navigator.push(context, MaterialPageRoute(builder: (context) => CreateDemandeScreen()));
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Chargement de vos demandes...',
              style: TextStyle(color: AppColors.gray600),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error,
                style: const TextStyle(
                  color: AppColors.gray700,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadDemandes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_demandes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 100,
                color: AppColors.gray300,
              ),
              const SizedBox(height: 20),
              const Text(
                'Aucune demande trouvée',
                style: TextStyle(
                  color: AppColors.gray700,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Vous n\'avez pas encore fait de demande de location.',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Faire une demande'),

              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDemandes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _demandes.length,
        itemBuilder: (context, index) {
          return _buildDemandeCard(_demandes[index]);
        },
      ),
    );
  }

  Widget _buildDemandeCard(DemandeLocationResponse demande) {
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
            // En-tête avec référence et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demande #${demande.id ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        demande.bienReference ?? 'Bien non spécifié',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatutChip(demande.statut ?? 'inconnu'),
              ],
            ),

            const SizedBox(height: 16),

            // Adresse du bien
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${demande.bienAdresse ?? ''}, ${demande.bienVille ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dates et durée
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Début: ${_formatDate(demande.dateDebut)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                      ),
                      Text(
                        'Durée: ${demande.dureeContrat ?? 0} mois',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Message si présent
            if (demande.message != null && demande.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Votre message:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      demande.message!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Motif de refus si présent
            if (demande.motifRefus != null && demande.motifRefus!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Motif de refus:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      demande.motifRefus!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Date de traitement si présente
            if (demande.dateTraitement != null) ...[
              const SizedBox(height: 12),
              Text(
                'Traité le: ${_formatDate(demande.dateTraitement)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Prix mensuel
            if (demande.montantMensuel != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${demande.montantMensuel} €/mois',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}