import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';

class PaiementsScreen extends StatefulWidget {
  const PaiementsScreen({super.key});

  @override
  State<PaiementsScreen> createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends State<PaiementsScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  User? _currentUser;
  List<dynamic> _paiements = [];
  bool _isLoading = true;
  String _error = '';
  int _selectedTab = 0; // 0: Tous, 1: En retard, 2: Payés

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('🔄 Chargement des paiements...');

      // 1. Récupérer le profil utilisateur
      final user = await _authService.getProfile();
      _currentUser = user;

      // 2. Charger les paiements depuis le vrai endpoint
      final response = await _apiService.get('/payments/locataire/${user.id}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        // Adapter selon la structure de la réponse
        List<dynamic> paiementsList = [];

        if (data is List) {
          paiementsList = data;
        } else if (data is Map && data.containsKey('content')) {
          paiementsList = data['content'] is List ? data['content'] : [];
        } else if (data is Map && data.containsKey('data')) {
          paiementsList = data['data'] is List ? data['data'] : [];
        }

        setState(() {
          _paiements = paiementsList;
          _isLoading = false;
          _error = '';
        });

        print('✅ ${_paiements.length} paiements chargés');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur chargement paiements: $e');
      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger les paiements';
      });
    }
  }

  List<dynamic> _getFilteredPaiements() {
    if (_selectedTab == 0) return _paiements;

    return _paiements.where((paiement) {
      final statut = paiement['statut']?.toString() ?? '';
      if (_selectedTab == 1) {
        return statut == 'EN_RETARD' ||
               statut == 'OVERDUE' ||
               paiement['estEnRetard'] == true;
      } else if (_selectedTab == 2) {
        return statut == 'COMPLETED' ||
               statut == 'CAPTURED' ||
               statut == 'PAYE' ||
               paiement['capturedAt'] != null;
      }
      return false;
    }).toList();
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.contains('T')) {
        dateStr = dateStr.split('T')[0];
      }
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String statut) {
    final statutStr = statut.toString().toUpperCase();
    switch (statutStr) {
      case 'COMPLETED':
      case 'CAPTURED':
      case 'PAYE':
        return Colors.green;
      case 'PENDING':
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'EN_RETARD':
      case 'OVERDUE':
        return Colors.red;
      case 'CANCELLED':
      case 'ANNULE':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusText(String statut) {
    final statutStr = statut.toString().toUpperCase();
    switch (statutStr) {
      case 'COMPLETED':
      case 'CAPTURED':
        return 'Payé';
      case 'PENDING':
        return 'En attente';
      case 'EN_RETARD':
      case 'OVERDUE':
        return 'En retard';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return statut;
    }
  }

  Widget _buildPaiementCard(Map<String, dynamic> paiement) {
    final statut = paiement['statut']?.toString() ?? '';
    final montant = paiement['montantTotal'] ?? paiement['montant'] ?? 0;
    final isEnRetard = statut == 'EN_RETARD' || statut == 'OVERDUE' || paiement['estEnRetard'] == true;
    final isPaye = statut == 'COMPLETED' || statut == 'CAPTURED' || paiement['capturedAt'] != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isEnRetard ? Colors.red.withOpacity(0.3) : Colors.transparent,
          width: isEnRetard ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(statut).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (isEnRetard)
                        Icon(Icons.warning, color: Colors.red, size: 14),
                      if (isEnRetard) const SizedBox(width: 4),
                      Text(
                        _getStatusText(statut),
                        style: TextStyle(
                          color: _getStatusColor(statut),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  paiement['reference'] ?? 'N/A',
                  style: TextStyle(
                    color: AppColors.greyMedium,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Détails
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paiement['periode'] ??
                        'Loyer ${paiement['moisConcerne'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (paiement['dateEcheance'] != null)
                        Text(
                          'Échéance: ${_formatDate(paiement['dateEcheance'])}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.greyDark,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(montant is num ? montant.toDouble() : 0.0).toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isEnRetard ? Colors.red : AppColors.primary,
                      ),
                    ),
                    if (paiement['montantCharges'] != null && (paiement['montantCharges'] as num) > 0)
                      Text(
                        'dont ${(paiement['montantCharges'] as num).toStringAsFixed(2)} DH charges',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.greyMedium,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Informations supplémentaires
            if (paiement['capturedAt'] != null)
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Payé le ${_formatDate(paiement['capturedAt'])}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (paiement['modePaiement'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        paiement['modePaiement'].toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),

            if (isEnRetard)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Paiement en retard - Veuillez régulariser',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (!isPaye && !isEnRetard)
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.orange, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'À payer avant le ${paiement['dateEcheance'] != null ? _formatDate(paiement['dateEcheance']) : 'prochaine échéance'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                'Chargement de vos paiements...',
                style: TextStyle(
                  color: AppColors.greyDark,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredPaiements = _getFilteredPaiements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes paiements'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('Tous', 0, _paiements.length),
                  _buildTabButton('En retard', 1,
                    _paiements.where((p) =>
                      (p['statut']?.toString() ?? '').contains('RETARD') ||
                      (p['statut']?.toString() ?? '').contains('OVERDUE') ||
                      p['estEnRetard'] == true
                    ).length
                  ),
                  _buildTabButton('Payés', 2,
                    _paiements.where((p) =>
                      (p['statut']?.toString() ?? '').contains('COMPLETED') ||
                      (p['statut']?.toString() ?? '').contains('CAPTURED') ||
                      p['capturedAt'] != null
                    ).length
                  ),
                ],
              ),
            ),
          ),

          // Liste
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: filteredPaiements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _error.isEmpty
                              ? 'Aucun paiement trouvé'
                              : _error,
                            style: TextStyle(
                              color: AppColors.greyDark,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_error.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Réessayer'),
                              ),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPaiements.length,
                      itemBuilder: (context, index) {
                        final paiement = filteredPaiements[index] as Map<String, dynamic>;
                        return _buildPaiementCard(paiement);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index, int count) {
    return TextButton(
      onPressed: () => setState(() => _selectedTab = index),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        foregroundColor: _selectedTab == index ? AppColors.primary : AppColors.greyDark,
        backgroundColor: _selectedTab == index ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
      ),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _selectedTab == index
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedTab == index ? AppColors.primary : Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}