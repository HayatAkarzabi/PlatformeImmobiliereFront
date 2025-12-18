import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class ReclamationsScreen extends StatefulWidget {
  const ReclamationsScreen({super.key});

  @override
  State<ReclamationsScreen> createState() => _ReclamationsScreenState();
}

class _ReclamationsScreenState extends State<ReclamationsScreen> {
  final List<Map<String, dynamic>> _reclamations = [
    {
      'id': 1,
      'titre': 'Fuite d\'eau dans la salle de bain',
      'description': 'Fuite persistante sous le lavabo depuis 3 jours',
      'date': '2024-01-10',
      'statut': 'EN_COURS',
      'urgence': true,
    },
    {
      'id': 2,
      'titre': 'Problème de chauffage',
      'description': 'Le chauffage ne fonctionne pas dans le salon',
      'date': '2024-01-05',
      'statut': 'RESOLU',
      'urgence': false,
    },
    {
      'id': 3,
      'titre': 'Porte d\'entrée difficile à fermer',
      'description': 'La porte grince et nécessite une poussée forte',
      'date': '2023-12-20',
      'statut': 'EN_ATTENTE',
      'urgence': false,
    },
  ];

  String _formatDate(String dateStr) {
    try {
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
    switch (statut) {
      case 'EN_COURS':
        return AppColors.orange600;
      case 'RESOLU':
        return AppColors.green600;
      case 'EN_ATTENTE':
        return AppColors.gray600;
      default:
        return AppColors.gray500;
    }
  }

  String _getStatusText(String statut) {
    switch (statut) {
      case 'EN_COURS':
        return 'En cours';
      case 'RESOLU':
        return 'Résolu';
      case 'EN_ATTENTE':
        return 'En attente';
      default:
        return statut;
    }
  }

  Widget _buildReclamationCard(Map<String, dynamic> reclamation) {
    final isUrgent = reclamation['urgence'] as bool;

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
            color: _getStatusColor(reclamation['statut'] as String)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            reclamation['statut'] == 'RESOLU'
                ? Icons.check_circle_rounded
                : Icons.warning_rounded,
            color: _getStatusColor(reclamation['statut'] as String),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                reclamation['titre'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isUrgent)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.red50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'URGENT',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.red600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              reclamation['description'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _formatDate(reclamation['date'] as String),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reclamation['statut'] as String)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(reclamation['statut'] as String),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(reclamation['statut'] as String),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showReclamationDetails(reclamation),
      ),
    );
  }

  void _showReclamationDetails(Map<String, dynamic> reclamation) {
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
                      reclamation['titre'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (reclamation['urgence'] as bool)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.red600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                  _getStatusColor(reclamation['statut'] as String)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(reclamation['statut'] as String),
                  style: TextStyle(
                    color: _getStatusColor(reclamation['statut'] as String),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reclamation['description'] as String,
                style: const TextStyle(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Date', _formatDate(reclamation['date'] as String)),
              _buildDetailRow('Statut', _getStatusText(reclamation['statut'] as String)),
              const SizedBox(height: 20),
              if (reclamation['statut'] != 'RESOLU')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Mettre à jour'),
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

  void _showNewReclamationDialog() {
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
              const Text(
                'Nouvelle réclamation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  hintText: 'Ex: Fuite d\'eau, problème électrique...',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez le problème en détail...',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (value) {}),
                  const Text('Urgent'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Réclamation envoyée'),
                      ),
                    );
                  },
                  child: const Text('Envoyer la réclamation'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réclamations'),
      ),
      body: Column(
        children: [
          // Statistiques
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.orange50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _reclamations
                              .where((r) => r['statut'] == 'EN_COURS')
                              .length
                              .toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'En cours',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _reclamations
                              .where((r) => r['statut'] == 'RESOLU')
                              .length
                              .toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Résolues',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _reclamations
                              .where((r) => r['urgence'] == true)
                              .length
                              .toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.red600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Urgentes',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _reclamations.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 60,
                    color: AppColors.gray300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune réclamation',
                    style: TextStyle(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            )
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._reclamations.map(_buildReclamationCard),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewReclamationDialog,
        backgroundColor: AppColors.blue600,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}