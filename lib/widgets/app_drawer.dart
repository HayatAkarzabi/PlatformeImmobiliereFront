// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../screens/home/home_screen.dart';
// import '../screens/demandes/mes_demandes_screen.dart';
// import '../screens/contrats/contrats_screen.dart';
// import '../screens/paiements/paiements_screen.dart';
// import '../screens/biens/mes_biens_screen.dart';
// import '../screens/reclamations/reclamations_screen.dart';
// import '../screens/notifications/notifications_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../services/auth_service.dart';
// import '../models/user.dart';
// import '../theme/app_color.dart';
//
// class AppDrawer extends StatefulWidget {
//   const AppDrawer({super.key});
//
//   @override
//   State<AppDrawer> createState() => _AppDrawerState();
// }
//
// class _AppDrawerState extends State<AppDrawer> {
//   final AuthService _authService = AuthService();
//   User? _currentUser;
//   String _userRole = 'LOCATAIRE';
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final role = prefs.getString('user_role') ?? 'LOCATAIRE';
//
//       final user = await _authService.getProfile();
//
//       setState(() {
//         _currentUser = user;
//         _userRole = role;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('❌ Erreur chargement utilisateur: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   String _getUserTypeText() {
//     switch (_userRole) {
//       case 'LOCATAIRE':
//         return 'Locataire';
//       case 'PROPRIETAIRE':
//         return 'Propriétaire';
//       case 'ADMIN':
//         return 'Administrateur';
//       default:
//         return 'Utilisateur';
//     }
//   }
//
//   Color _getUserTypeColor() {
//     switch (_userRole) {
//       case 'LOCATAIRE':
//         return Colors.blue;
//       case 'PROPRIETAIRE':
//         return Colors.green;
//       case 'ADMIN':
//         return Colors.purple;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   Widget _buildDrawerHeader() {
//     if (_isLoading) {
//       return const DrawerHeader(
//         decoration: BoxDecoration(
//           color: AppColors.primary,
//         ),
//         child: Center(
//           child: CircularProgressIndicator(color: Colors.white),
//         ),
//       );
//     }
//
//     final initials = _currentUser?.fullName.isNotEmpty == true
//         ? _currentUser!.fullName.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
//         : 'U';
//
//     return DrawerHeader(
//       decoration: const BoxDecoration(
//         color: AppColors.primary,
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary,
//             AppColors.secondary,
//           ],
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Badge type utilisateur
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             decoration: BoxDecoration(
//               color: _getUserTypeColor().withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: _getUserTypeColor()),
//             ),
//             child: Text(
//               _getUserTypeText(),
//               style: TextStyle(
//                 color: _getUserTypeColor(),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Avatar et informations
//           Row(
//             children: [
//               // Avatar
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 5,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Text(
//                     initials,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(width: 16),
//
//               // Informations utilisateur
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _currentUser?.fullName ?? 'Utilisateur',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _currentUser?.email ?? '',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<DrawerItem> _getDrawerItems() {
//     final items = <DrawerItem>[];
//
//     // Menu principal (commun à tous)
//     items.addAll([
//       DrawerItem(
//         title: 'Accueil',
//         icon: Icons.home_rounded,
//         route: '/',
//         badgeCount: 0,
//       ),
//       DrawerItem(
//         title: 'Rechercher un bien',
//         icon: Icons.search_rounded,
//         route: '/home',
//         badgeCount: 0,
//       ),
//     ]);
//
//     // Menu selon le rôle
//     if (_userRole == 'LOCATAIRE') {
//       items.addAll([
//         DrawerItem(
//           title: 'Mes Demandes',
//           icon: Icons.request_quote_rounded,
//           route: '/mes_locataires_screen.dart-demandes',
//           badgeCount: 0,
//         ),
//         DrawerItem(
//           title: 'Mes Contrats',
//           icon: Icons.contract_rounded,
//           route: '/contrats',
//           badgeCount: 0,
//         ),
//         DrawerItem(
//           title: 'Mes Paiements',
//           icon: Icons.payment_rounded,
//           route: '/paiements',
//           badgeCount: 0,
//         ),
//         DrawerItem(
//           title: 'Mes Réclamations',
//           icon: Icons.report_problem_rounded,
//           route: '/reclamations',
//           badgeCount: 0,
//         ),
//       ]);
//     } else if (_userRole == 'PROPRIETAIRE') {
//       items.addAll([
//         DrawerItem(
//           title: 'Mes Biens',
//           icon: Icons.house_rounded,
//           route: '/mes_locataires_screen.dart-biens',
//           badgeCount: 0,
//         ),
//         DrawerItem(
//           title: 'Demandes reçues',
//           icon: Icons.inbox_rounded,
//           route: '/demandes-recues',
//           badgeCount: 0,
//         ),
//         DrawerItem(
//           title: 'Contrats en cours',
//           icon: Icons.description_rounded,
//           route: '/contrats-proprietaire',
//           badgeCount: 0,
//         ),
//         DrawerItem(
//           title: 'Paiements attendus',
//           icon: Icons.account_balance_wallet_rounded,
//           route: '/paiements-proprietaire',
//           badgeCount: 0,
//         ),
//       ]);
//     } else if (_userRole == 'ADMIN') {
//       items.addAll([
//         DrawerItem(
//           title: 'Gestion Biens',
//           icon: Icons.manage_search_rounded,
//           route: '/admin/biens',
//           badgeCount: 0,
//         ),
//         DrawerItem(
//           title: 'Gestion Utilisateurs',
//           icon: Icons.people_alt_rounded,
//           route: '/admin/utilisateurs',
//           badgeCount: 0,
//         ),
//         DrawerItem(
//           title: 'Validation Demandes',
//           icon: Icons.task_alt_rounded,
//           route: '/admin/validation',
//           badgeCount: 0,
//         ),
//         DrawerItem(
//           title: 'Statistiques',
//           icon: Icons.bar_chart_rounded,
//           route: '/admin/stats',
//           badgeCount: 0,
//         ),
//       ]);
//     }
//
//     // Menu commun (fin)
//     items.addAll([
//       DrawerItem(
//         title: 'Notifications',
//         icon: Icons.notifications_rounded,
//         route: '/notifications',
//         badgeCount: 0, // À remplacer par le vrai compteur
//       ),
//       DrawerItem(
//         title: 'Mon Profil',
//         icon: Icons.person_rounded,
//         route: '/profile',
//         badgeCount: 0,
//       ),
//       DrawerItem(
//         title: 'Paramètres',
//         icon: Icons.settings_rounded,
//         route: '/settings',
//         badgeCount: 0,
//       ),
//       DrawerItem(
//         title: 'Aide & Support',
//         icon: Icons.help_rounded,
//         route: '/help',
//         badgeCount: 0,
//       ),
//     ]);
//
//     return items;
//   }
//
//   void _navigateTo(String route) {
//     Navigator.pop(context); // Fermer le drawer
//
//     switch (route) {
//       case '/':
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//         );
//         break;
//       case '/home':
//         Navigator.pushNamed(context, '/home');
//         break;
//       case '/mes_locataires_screen.dart-demandes':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const MesDemandesScreen()),
//         );
//         break;
//       case '/contrats':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const ContratsScreen()),
//         );
//         break;
//       case '/paiements':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const PaiementsScreen()),
//         );
//         break;
//       case '/mes_locataires_screen.dart-biens':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const MesBiensScreen()),
//         );
//         break;
//       case '/reclamations':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const ReclamationsScreen()),
//         );
//         break;
//       case '/notifications':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const NotificationsScreen()),
//         );
//         break;
//       case '/profile':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const ProfileScreen()),
//         );
//         break;
//       default:
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Page $route - Bientôt disponible'),
//             backgroundColor: AppColors.primary,
//           ),
//         );
//     }
//   }
//
//   Future<void> _logout() async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Déconnexion'),
//         content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Annuler'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context); // Fermer la dialog
//               Navigator.pop(context); // Fermer le drawer
//               await _authService.logout();
//               if (mounted) {
//                 Navigator.pushReplacementNamed(context, '/login');
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Déconnexion'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final drawerItems = _getDrawerItems();
//
//     return Drawer(
//       width: 280,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topRight: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header
//           _buildDrawerHeader(),
//
//           // Liste des éléments
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.only(top: 8),
//               itemCount: drawerItems.length,
//               itemBuilder: (context, index) {
//                 final item = drawerItems[index];
//                 return _buildDrawerListItem(item);
//               },
//             ),
//           ),
//
//           // Section déconnexion
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               border: Border(
//                 top: BorderSide(color: Colors.grey[200]!),
//               ),
//             ),
//             child: ListTile(
//               leading: Icon(Icons.logout_rounded, color: Colors.red[400]),
//               title: Text(
//                 'Déconnexion',
//                 style: TextStyle(
//                   color: Colors.red[400],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               onTap: _logout,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               tileColor: Colors.red[50],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerListItem(DrawerItem item) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: ListTile(
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             item.icon,
//             color: AppColors.primary,
//             size: 22,
//           ),
//         ),
//         title: Text(
//           item.title,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         trailing: item.badgeCount > 0
//             ? Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.red,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             item.badgeCount > 9 ? '9+' : item.badgeCount.toString(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         )
//             : null,
//         onTap: () => _navigateTo(item.route),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//       ),
//     );
//   }
// }
//
// class DrawerItem {
//   final String title;
//   final IconData icon;
//   final String route;
//   final int badgeCount;
//
//   DrawerItem({
//     required this.title,
//     required this.icon,
//     required this.route,
//     this.badgeCount = 0,
//   });
// }