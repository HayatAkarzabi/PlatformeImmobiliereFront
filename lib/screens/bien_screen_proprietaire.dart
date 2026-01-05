import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/bien.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../theme/app_color.dart';
import '../models/user.dart';

class MesBiensProprietaireScreen extends StatefulWidget {
  const MesBiensProprietaireScreen({super.key});

  @override
  State<MesBiensProprietaireScreen> createState() => _MesBiensProprietaireScreenState();
}

class _MesBiensProprietaireScreenState extends State<MesBiensProprietaireScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  List<Bien> _biens = [];
  bool _isLoading = true;
  String _error = '';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserAndBiens();
  }

  Future<void> _loadUserAndBiens() async {
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

      print('🔄 Chargement des biens du propriétaire ${user.id}...');

      // 2. Charger les biens de ce propriétaire spécifique
      final response = await _apiService.get('/api/v1/biens/proprietaire/${user.id}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _biens = data.map((json) => Bien.fromJson(json)).toList();
          _isLoading = false;
        });
        print('✅ ${_biens.length} biens chargés pour le propriétaire');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur chargement biens propriétaire: $e');
      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger vos biens';
      });
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'DISPONIBLE':
        return Colors.green;
      case 'LOUE':
        return Colors.deepPurple;
      case 'EN_MAINTENANCE':
        return Colors.orange;
      default:
        return AppColors.gray500;
    }
  }

  String _formatStatus(String statut) {
    switch (statut) {
      case 'DISPONIBLE': return 'Disponible';
      case 'LOUE': return 'Loué';
      case 'EN_MAINTENANCE': return 'Maintenance';
      default: return statut;
    }
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

  Widget _buildBienCard(Bien bien) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/proprietaire/bien-details',
            arguments: bien,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image du bien
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.gray100,
                  image: bien.photos.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(bien.photos.first),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: bien.photos.isEmpty
                    ? Center(
                  child: Icon(
                    Icons.apartment_outlined,
                    size: 32,
                    color: AppColors.gray400,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              // Informations du bien
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${_formatType(bien.typeBien)} - ${bien.ville}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(bien.statut).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getStatusColor(bien.statut).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _formatStatus(bien.statut),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getStatusColor(bien.statut),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bien.adresse,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.gray600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bien.loyerMensuel.toStringAsFixed(0)} DH',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              'Loyer mensuel',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bien.charges.toStringAsFixed(0)} DH',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray700,
                              ),
                            ),
                            Text(
                              'Charges',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bien.caution.toStringAsFixed(0)} DH',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray700,
                              ),
                            ),
                            Text(
                              'Caution',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Réf: ${bien.reference}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${bien.surface.toStringAsFixed(0)} m²',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
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
              fontSize: 24,
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mes Biens'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.gray900,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Biens'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadUserAndBiens,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gray100,
            ),
          ),
        ],
      ),
      body: _error.isNotEmpty
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
              onPressed: _loadUserAndBiens,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadUserAndBiens,
        color: Colors.deepPurple,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Résumé statistique
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      _biens.length,
                      Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Loués',
                      _biens.where((b) => b.statut == 'LOUE').length,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Disponibles',
                      _biens.where((b) => b.statut == 'DISPONIBLE').length,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Titre de la liste
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tous mes_locataires_screen.dart biens',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  Text(
                    '${_biens.length} bien${_biens.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Liste des biens
              if (_biens.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.apartment_outlined,
                        size: 64,
                        color: AppColors.gray300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucun bien publié',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Commencez par publier votre premier bien',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/proprietaire/nouveau-bien');
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Publier un bien'),
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
                  children: _biens.map((bien) {
                    return Column(
                      children: [
                        _buildBienCard(bien),
                        if (_biens.indexOf(bien) < _biens.length - 1)
                          const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/proprietaire/nouveau-bien');
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}