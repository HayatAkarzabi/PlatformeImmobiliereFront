// screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _hasUnread = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    // Données simulées
    setState(() {
      _notifications = [
        {
          'id': 1,
          'title': 'Échéance de paiement',
          'message': 'Le paiement du loyer de février est dû le 05/02/2024',
          'type': 'payment',
          'date': 'Il y a 2 heures',
          'read': false,
          'action': '/paiements',
        },
        {
          'id': 2,
          'title': 'Réclamation mise à jour',
          'message': 'Votre réclamation "Fuite cuisine" est en cours de traitement',
          'type': 'reclamation',
          'date': 'Hier',
          'read': false,
          'action': '/reclamations',
        },
        {
          'id': 3,
          'title': 'Contrat expirant',
          'message': 'Votre contrat expire le 31/08/2024. Pensez au renouvellement',
          'type': 'contrat',
          'date': 'Il y a 2 jours',
          'read': true,
          'action': '/contrats',
        },
        {
          'id': 4,
          'title': 'Paiement confirmé',
          'message': 'Votre paiement de janvier a été validé. Quittance disponible',
          'type': 'payment',
          'date': 'Il y a 1 semaine',
          'read': true,
          'action': '/paiements',
        },
        {
          'id': 5,
          'title': 'Visite annuelle',
          'message': 'Visite de contrôle prévue le 15/02/2024',
          'type': 'info',
          'date': 'Il y a 1 semaine',
          'read': true,
          'action': null,
        },
      ];
    });
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    IconData icon;
    Color color;

    switch (notification['type']) {
      case 'payment':
        icon = Icons.payment;
        color = Colors.green;
        break;
      case 'reclamation':
        icon = Icons.report_problem;
        color = Colors.orange;
        break;
      case 'contrat':
        icon = Icons.contrast;
        color = AppColors.primary;
        break;
      default:
        icon = Icons.info;
        color = Colors.blue;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: !notification['read'] ? AppColors.primary.withOpacity(0.05) : Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification['title'],
                    style: TextStyle(
                      fontWeight: !notification['read'] ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!notification['read'])
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              notification['message'],
              style: TextStyle(
                color: AppColors.greyDark,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            notification['date'],
            style: TextStyle(
              color: AppColors.greyMedium,
              fontSize: 11,
            ),
          ),
        ),
        onTap: () {
          // Marquer comme lu
          setState(() {
            notification['read'] = true;
          });

          // Naviguer si action définie
          if (notification['action'] != null) {
            // TODO: Navigation vers l'écran correspondant
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigation vers: ${notification['action']}'),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        trailing: const Icon(Icons.chevron_right, color: AppColors.greyMedium),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
      _hasUnread = false;
    });
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer les notifications'),
        content: const Text('Voulez-vous effacer toutes les notifications ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
                _hasUnread = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Effacer tout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['read']).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Badge(
                label: Text(unreadCount.toString()),
                child: const Icon(Icons.mark_email_read),
              ),
              onPressed: _markAllAsRead,
              tooltip: 'Marquer tout comme lu',
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearAll,
            tooltip: 'Effacer tout',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune notification',
              style: TextStyle(
                color: AppColors.greyDark,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Vous serez informé ici des nouvelles activités',
              style: TextStyle(
                color: AppColors.greyMedium,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$unreadCount notification${unreadCount > 1 ? 's' : ''} non lue${unreadCount > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text('Tout marquer comme lu'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                _loadNotifications();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ..._notifications.map((notification) =>
                      _buildNotificationItem(notification)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}