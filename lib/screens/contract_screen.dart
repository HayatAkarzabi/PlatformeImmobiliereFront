import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_immobilier_front/screens/reclamations_contrat_screen.dart';
import '../models/contrat.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';
import 'create_reclamation_screen.dart';


class ContratsScreen extends StatefulWidget {
  const ContratsScreen({super.key});

  @override
  State<ContratsScreen> createState() => _ContratsScreenState();
}

class _ContratsScreenState extends State<ContratsScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  List<Contrat> _contrats = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadContrats();
  }

  Future<void> _loadContrats() async {
    try {
      print('🔄 Chargement des contrats...');

      // 1. Récupérer le profil utilisateur
      final user = await _authService.getProfile();

      // 2. Charger les contrats selon le type d'utilisateur
      if (user.type == 'LOCATAIRE') {
        // Utiliser le vrai endpoint pour mes_locataires_screen.dart contrats
        final response = await _apiService.get('/api/v1/contrats/mes-contrats');

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            _contrats = data.map((json) => Contrat.fromJson(json)).toList();
            _isLoading = false;
            _error = '';
          });
          print('✅ ${_contrats.length} contrats chargés');
        } else {
          throw Exception('Erreur serveur: ${response.statusCode}');
        }
      } else {
        throw Exception('Cette fonctionnalité est réservée aux locataires');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger les contrats';
      });
    }
  }

  Future<void> _downloadContratDocument(int contratId) async {
    try {
      final response = await _apiService.get('/api/v1/contrats/$contratId/document');

      if (response.statusCode == 200) {
        // TODO: Implémenter le téléchargement du PDF
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document du contrat téléchargé'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Document non disponible');
      }
    } catch (e) {
      print('❌ Erreur téléchargement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléchargement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
// AJOUTE CES 2 MÉTHODES APRÈS _downloadContratDocument :

// 1. Pour créer une réclamation
  void _creerReclamation(Contrat contrat) {
    Navigator.pop(context); // Ferme le bottom sheet

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReclamationScreen(contrat: contrat),
      ),
    );
  }

// 2. Pour voir les réclamations d'un contrat
  void _voirReclamations(Contrat contrat) {
    Navigator.pop(context); // Ferme le bottom sheet

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReclamationsContratScreen(contratId: contrat.id),
      ),
    );
  }
  // Fonction pour formater la date
  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('T')[0].split('-');
      if (parts.length >= 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'ACTIF':
        return AppColors.green600;
      case 'EXPIRE':
        return AppColors.orange600;
      case 'RESILIE':
        return AppColors.red600;
      default:
        return AppColors.gray500;
    }
  }

  Widget _buildContratCard(Contrat contrat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(contrat.statut).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            contrat.statut == 'ACTIF'
                ? Icons.contrast_rounded
                : Icons.archive_rounded,
            color: _getStatusColor(contrat.statut),
          ),
        ),
        title: Text(
          'Contrat ${contrat.reference}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Du ${_formatDate(contrat.dateDebut)} au ${_formatDate(contrat.dateFin)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(contrat.statut).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                contrat.statut,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(contrat.statut),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${contrat.loyerMensuel?.toStringAsFixed(2) ?? '0'} DH',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (contrat.charges != null && contrat.charges! > 0)
              Text(
                '+ ${contrat.charges!.toStringAsFixed(2)} DH charges',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.gray500,
                ),
              ),
          ],
        ),
        onTap: () => _showContratDetails(contrat),
      ),
    );
  }

  void _showContratDetails(Contrat contrat) {
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
              // DANS _showContratDetails, REMPLACE :
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadContratDocument(contrat.id),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Télécharger le contrat'),
                ),
              ),

// PAR CE BLOC COMPLET :
              const SizedBox(height: 20),

// 1. Bouton Télécharger PDF
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadContratDocument(contrat.id),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Télécharger le contrat (PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

// 2. Bouton Ajouter une réclamation (seulement si contrat ACTIF)
              if (contrat.statut == 'ACTIF')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _creerReclamation(contrat),
                    icon: const Icon(Icons.report_problem),
                    label: const Text('Signaler un problème'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

// 3. Bouton Voir les réclamations existantes
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _voirReclamations(contrat),
                  icon: const Icon(Icons.list),
                  label: const Text('Voir mes réclamations'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mes contrats'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mes contrats'),
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadContrats,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes contrats'),
        actions: [
          IconButton(
            onPressed: _loadContrats,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadContrats,
        child: _contrats.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_rounded,
                size: 60,
                color: AppColors.gray300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Vous n\'avez aucun contrat',
                style: TextStyle(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _contrats.length,
          itemBuilder: (context, index) {
            return _buildContratCard(_contrats[index]);
          },
        ),
      ),
    );
  }
}

