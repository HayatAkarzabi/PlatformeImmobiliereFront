import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/bien.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';
import 'mes_demandes_screen.dart';

class BiensScreen extends StatefulWidget {
  const BiensScreen({super.key});

  @override
  State<BiensScreen> createState() => _BiensScreenState();
}

class _BiensScreenState extends State<BiensScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  List<Bien> _biens = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadBiens();
  }

  Future<void> _loadBiens() async {
    try {
      print('🔄 Chargement des biens publics...');
      final response = await _apiService.get('/api/v1/biens/publics');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _biens = data.map((json) => Bien.fromJson(json)).toList();
          _isLoading = false;
          _error = '';
        });
        print('✅ ${_biens.length} biens chargés');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger les biens';
      });
    }
  }

  // Reste du code inchangé (garder toutes les fonctions existantes: _getStatusColor, _buildBienCard, etc.)
  // ...



  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'DISPONIBLE':
        return AppColors.green600;
      case 'LOUE':
        return AppColors.blue600;
      case 'EN_MAINTENANCE':
        return AppColors.orange600;
      default:
        return AppColors.gray500;
    }
  }

  Widget _buildBienCard(Bien bien) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              image: bien.photos.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(bien.photos.first),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: bien.photos.isEmpty
                ? const Center(
              child: Icon(
                Icons.home_rounded,
                size: 60,
                color: AppColors.gray400,
              ),
            )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${bien.typeBien} - ${bien.ville}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(bien.statut).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        bien.statut,
                        style: TextStyle(
                          fontSize: 10,
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
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bien.adresse,
                        style: const TextStyle(
                          fontSize: 12,
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
                          '${bien.loyerMensuel.toStringAsFixed(2)} DH',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue600,
                          ),
                        ),
                        const Text(
                          'Loyer mensuel',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    if (bien.charges > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${bien.charges.toStringAsFixed(2)} DH',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Charges',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${bien.caution.toStringAsFixed(2)} DH',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Caution',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showBienDetails(bien),
                    child: const Text('Voir les détails'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBienDetails(Bien bien) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${bien.typeBien} - ${bien.ville}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(bien.statut).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bien.statut,
                      style: TextStyle(
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
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      bien.adresse,
                      style: const TextStyle(
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Référence', bien.reference),
              _buildDetailRow('Ville', bien.ville),
              _buildDetailRow('Code postal', bien.codePostal),
              _buildDetailRow('Type', bien.typeBien),
              _buildDetailRow('Loyer mensuel',
                  '${bien.loyerMensuel.toStringAsFixed(2)} DH'),
              if (bien.charges > 0)
                _buildDetailRow(
                    'Charges', '${bien.charges.toStringAsFixed(2)} DH'),
              _buildDetailRow(
                  'Caution', '${bien.caution.toStringAsFixed(2)} DH'),
              _buildDetailRow('Statut', bien.statut),
              const SizedBox(height: 20),
              // Dans _showBienDetails, remplacez le bouton:
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Fermer la bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DemandeLocationScreen(bien: bien),
                      ),
                    );
                  },
                  child: const Text('Demander la location'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Biens disponibles'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Biens disponibles'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.gray400,
              ),
              const SizedBox(height: 16),
              Text(
                _error,
                style: const TextStyle(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadBiens,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biens disponibles'),
        actions: [
          IconButton(
            onPressed: _loadBiens,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBiens,
        child: _biens.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_rounded,
                size: 60,
                color: AppColors.gray300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucun bien disponible pour le moment',
                style: TextStyle(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _biens.length,
          itemBuilder: (context, index) {
            return _buildBienCard(_biens[index]);
          },
        ),
      ),
    );
  }
}