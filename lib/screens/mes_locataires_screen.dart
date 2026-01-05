import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/bien.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../theme/app_color.dart';

class MesLocatairesProprietaireScreen extends StatefulWidget {
  const MesLocatairesProprietaireScreen({super.key});

  @override
  State<MesLocatairesProprietaireScreen> createState() => _MesLocatairesProprietaireScreenState();
}

class _MesLocatairesProprietaireScreenState extends State<MesLocatairesProprietaireScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _locataires = [];
  List<Bien> _biensLoues = [];
  bool _isLoading = true;
  String _error = '';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // 1. Charger l'utilisateur courant
      final user = await _authService.getProfile();
      setState(() {
        _currentUser = user;
      });

      // 2. Charger les biens du propriétaire
      final response = await _apiService.get('/api/v1/biens/proprietaire/${user.id}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Bien> tousBiens = data.map((json) => Bien.fromJson(json)).toList();

        // 3. Filtrer les biens loués
        _biensLoues = tousBiens.where((bien) => bien.statut == 'LOUE').toList();

        // 4. Simuler des données de locataires (à remplacer par votre API réelle)
        await _simulerLocataires();

        setState(() {
          _isLoading = false;
        });

        print('✅ ${_biensLoues.length} biens loués trouvés');
        print('✅ ${_locataires.length} locataires chargés');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur chargement locataires: $e');
      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger les locataires';
      });
    }
  }

  Future<void> _simulerLocataires() async {
    // Simulation de données en attendant votre backend
    // Dans votre cas réel, vous aurez un endpoint comme /api/v1/proprietaire/{id}/locataires

    _locataires = _biensLoues.asMap().entries.map((entry) {
      final bien = entry.value;
      final index = entry.key + 1;

      return {
        'id': index,
        'nom': _genererNom(index),
        'email': 'locataire$index@example.com',
        'telephone': _genererTelephone(index),
        'bienId': bien.id,
        'bienTitre': '${_formatType(bien.typeBien)} - ${bien.ville}',
        'bienAdresse': bien.adresse,
        'bienLoyer': bien.loyerMensuel,
        'dateDebut': _genererDateDebut(index),
        'dateFin': _genererDateFin(index),
        'statutContrat': _genererStatutContrat(index),
        'prochainPaiement': _genererProchainPaiement(),
        'historiquePaiements': _genererHistoriquePaiements(),
      };
    }).toList();
  }

  // Fonctions de génération de données fictives
  String _genererNom(int index) {
    final noms = ['Ahmed Hassan', 'Fatima Zahra', 'Mohammed Ali', 'Amina Boukhari', 'Karim El Mansouri'];
    return noms[(index - 1) % noms.length];
  }

  String _genererTelephone(int index) {
    return '06${10000000 + index * 111111}';
  }

  String _genererDateDebut(int index) {
    final mois = DateTime.now().month - index;
    final date = DateTime(DateTime.now().year, mois.clamp(1, 12), 1);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _genererDateFin(int index) {
    final date = DateTime.now().add(Duration(days: 365 + index * 30));
    return '${date.day}/${date.month}/${date.year}';
  }

  String _genererStatutContrat(int index) {
    final statuts = ['ACTIF', 'ACTIF', 'À RENOUVELER', 'ACTIF', 'TERMINÉ'];
    return statuts[(index - 1) % statuts.length];
  }

  String _genererProchainPaiement() {
    final date = DateTime.now().add(const Duration(days: 5));
    return '${date.day}/${date.month}/${date.year}';
  }

  List<Map<String, dynamic>> _genererHistoriquePaiements() {
    return [
      {'mois': 'Janvier', 'montant': 3500, 'statut': 'PAYÉ', 'date': '05/01/2024'},
      {'mois': 'Février', 'montant': 3500, 'statut': 'PAYÉ', 'date': '05/02/2024'},
      {'mois': 'Mars', 'montant': 3500, 'statut': 'EN ATTENTE', 'date': '05/03/2024'},
    ];
  }

  String _formatType(String type) {
    switch (type) {
      case 'APPARTEMENT': return 'Appartement';
      case 'MAISON': return 'Maison';
      case 'VILLA': return 'Villa';
      case 'STUDIO': return 'Studio';
      default: return type;
    }
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'ACTIF': return Colors.green;
      case 'À RENOUVELER': return Colors.orange;
      case 'TERMINÉ': return Colors.red;
      default: return AppColors.gray500;
    }
  }

  Widget _buildLocataireCard(Map<String, dynamic> locataire) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          child: Text(
            locataire['nom'].toString().substring(0, 1),
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          locataire['nom'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              locataire['bienTitre'],
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatutColor(locataire['statutContrat']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatutColor(locataire['statutContrat']).withOpacity(0.2),
                ),
              ),
              child: Text(
                locataire['statutContrat'],
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatutColor(locataire['statutContrat']),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.expand_more_rounded, color: AppColors.gray400),
        children: [
          Divider(color: AppColors.gray200),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                // Informations de contact
                _buildInfoRow('Email', locataire['email'], Icons.email_outlined),
                _buildInfoRow('Téléphone', locataire['telephone'], Icons.phone_outlined),
                _buildInfoRow('Adresse du bien', locataire['bienAdresse'], Icons.location_on_outlined),

                const SizedBox(height: 16),

                // Informations financières
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Loyer mensuel',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray600,
                            ),
                          ),
                          Text(
                            '${locataire['bienLoyer'].toStringAsFixed(0)} DH',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prochain paiement',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray600,
                            ),
                          ),
                          Text(
                            locataire['prochainPaiement'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Dates du contrat
                Row(
                  children: [
                    Expanded(
                      child: _buildDateCard(
                        'Début',
                        locataire['dateDebut'],
                        Icons.calendar_today_outlined,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateCard(
                        'Fin',
                        locataire['dateFin'],
                        Icons.calendar_month_outlined,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _contacterLocataire(locataire);
                        },
                        icon: const Icon(Icons.message_outlined, size: 18),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _voirContrat(locataire);
                        },
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('Contrat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.gray500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String label, String date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _contacterLocataire(Map<String, dynamic> locataire) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter le locataire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${locataire['nom']}'),
            Text('Email: ${locataire['email']}'),
            Text('Téléphone: ${locataire['telephone']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implémenter l'appel téléphonique
              Navigator.pop(context);
            },
            child: const Text('Appeler'),
          ),
        ],
      ),
    );
  }

  void _voirContrat(Map<String, dynamic> locataire) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contrat de location'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Contrat #${DateTime.now().millisecondsSinceEpoch}'),
              const SizedBox(height: 16),
              Text('Locataire: ${locataire['nom']}'),
              Text('Bien: ${locataire['bienTitre']}'),
              Text('Adresse: ${locataire['bienAdresse']}'),
              Text('Loyer: ${locataire['bienLoyer']} DH/mois'),
              Text('Début: ${locataire['dateDebut']}'),
              Text('Fin: ${locataire['dateFin']}'),
              Text('Statut: ${locataire['statutContrat']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implémenter l'impression du contrat
              Navigator.pop(context);
            },
            child: const Text('Imprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Locataires'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadData,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gray100,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      )
          : _error.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 20),
            Text(
              _error,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.deepPurple,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistiques
              if (_locataires.isNotEmpty)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatsCard(
                            'Locataires actifs',
                            _locataires.where((l) => l['statutContrat'] == 'ACTIF').length,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatsCard(
                            'Biens loués',
                            _biensLoues.length,
                            Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatsCard(
                            'Revenu mensuel',
                            _locataires.fold(0, (sum, l) => sum + (l['bienLoyer'] as num).toInt()),
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatsCard(
                            'À renouveler',
                            _locataires.where((l) => l['statutContrat'] == 'À RENOUVELER').length,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Titre de la liste
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tous mes locataires',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  if (_locataires.isNotEmpty)
                    Text(
                      '${_locataires.length} locataire${_locataires.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Liste des locataires
              if (_locataires.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 64,
                        color: AppColors.gray300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucun locataire',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Vos locataires apparaîtront ici',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lorsque vous louez un bien',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/proprietaire/mes-biens-proprietaire');
                        },
                        icon: const Icon(Icons.apartment_outlined),
                        label: const Text('Voir mes biens'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _locataires.map((locataire) {
                    return _buildLocataireCard(locataire);
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}