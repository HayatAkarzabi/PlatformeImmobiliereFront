// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../services/api_service.dart';
// import '../models/user.dart';
// import '../theme/app_color.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final AuthService _authService = AuthService();
//   final ApiService _apiService = ApiService();
//   User? _currentUser;
//   bool _isLoading = true;
//   bool _refreshing = false;
//   Map<String, dynamic> _userStats = {
//     'demandes': 0,
//     'contrats': 0,
//     'paiements': 0,
//     'biens_loues': 0,
//   };
//
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     try {
//       print('🔄 Chargement des données utilisateur...');
//
//       // Récupérer le profil utilisateur
//       final user = await _authService.getProfile();
//       print('✅ Utilisateur chargé: ${user.fullName} (ID: ${user.id})');
//
//       // Vérifier que l'utilisateur est un locataire
//       if (user.type != 'LOCATAIRE') {
//         print('⚠️ Attention: L\'utilisateur n\'est pas un locataire');
//         // On continue mais on affichera 0 pour les stats
//       }
//
//       // Charger les statistiques réelles depuis l'API
//       await _loadUserStatistics(user.id, user.type);
//
//       setState(() {
//         _currentUser = user;
//         _isLoading = false;
//         _refreshing = false;
//       });
//
//     } catch (e) {
//       print('❌ Erreur: $e');
//       setState(() {
//         _isLoading = false;
//         _refreshing = false;
//       });
//     }
//   }
//
//   Future<void> _loadUserStatistics(int userId, String userType) async {
//     try {
//       Map<String, dynamic> stats = {
//         'demandes': 0,
//         'contrats': 0,
//         'paiements': 0,
//         'biens_loues': 0,
//       };
//
//       // Ne charger les stats que si l'utilisateur est un locataire
//       if (userType == 'LOCATAIRE') {
//
//         // 1. Récupérer les demandes de location
//         try {
//           final demandesResponse = await _apiService.get('/api/v1/demandes-location/mes-demandes');
//           if (demandesResponse.statusCode == 200) {
//             final demandes = jsonDecode(demandesResponse.body);
//             stats['demandes'] = demandes is List ? demandes.length : 0;
//             print('📋 Demandes récupérées: ${stats['demandes']}');
//           }
//         } catch (e) {
//           print('⚠️ Erreur chargement demandes: $e');
//         }
//
//         // 2. Récupérer les contrats du locataire
//         try {
//           final contratsResponse = await _apiService.get('/api/v1/contrats/mes-contrats');
//           if (contratsResponse.statusCode == 200) {
//             final contrats = jsonDecode(contratsResponse.body);
//             stats['contrats'] = contrats is List ? contrats.length : 0;
//
//             // Filtrer les contrats actifs seulement
//             if (contrats is List) {
//               final contratsActifs = contrats.where((contrat) =>
//               contrat['statut'] == 'ACTIF').length;
//               stats['biens_loues'] = contratsActifs;
//             }
//             print('📄 Contrats récupérés: ${stats['contrats']} (actifs: ${stats['biens_loues']})');
//           }
//         } catch (e) {
//           print('⚠️ Erreur chargement contrats: $e');
//         }
//
//         // 3. Récupérer les paiements du locataire
//         try {
//           final paiementsResponse = await _apiService.get('/payments/locataire/$userId');
//           if (paiementsResponse.statusCode == 200) {
//             final paiements = jsonDecode(paiementsResponse.body);
//             // La réponse peut être un objet avec une propriété 'content' ou directement une liste
//             if (paiements is Map && paiements.containsKey('content')) {
//               stats['paiements'] = paiements['content'] is List ? paiements['content'].length : 0;
//             } else if (paiements is List) {
//               stats['paiements'] = paiements.length;
//             }
//             print('💰 Paiements récupérés: ${stats['paiements']}');
//           }
//         } catch (e) {
//           print('⚠️ Erreur chargement paiements: $e');
//         }
//
//       } else {
//         // Pour les non-locataires, on met tout à 0
//         print('ℹ️ Utilisateur non locataire, statistiques à 0');
//       }
//
//       setState(() {
//         _userStats = stats;
//       });
//
//       print('📊 Statistiques finales: $stats');
//
//     } catch (e) {
//       print('⚠️ Erreur générale chargement statistiques: $e');
//       // En cas d'erreur, on garde les valeurs à 0
//       setState(() {
//         _userStats = {
//           'demandes': 0,
//           'contrats': 0,
//           'paiements': 0,
//           'biens_loues': 0,
//         };
//       });
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
//               Navigator.pop(context);
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
//   Future<void> _refreshData() async {
//     setState(() {
//       _refreshing = true;
//     });
//     await _loadUserData();
//   }
//
//   Widget _buildHeader() {
//     final userType = _currentUser?.type ?? 'LOCATAIRE';
//     final userTypeText = userType == 'LOCATAIRE'
//         ? 'Locataire'
//         : userType == 'PROPRIETAIRE'
//         ? 'Propriétaire'
//         : 'Administrateur';
//
//     final initials = (_currentUser?.firstName?.isNotEmpty ?? false)
//         ? _currentUser!.firstName![0].toUpperCase()
//         : (_currentUser?.lastName?.isNotEmpty ?? false)
//         ? _currentUser!.lastName![0].toUpperCase()
//         : 'U';
//
//     return Container(
//       padding: const EdgeInsets.only(
//         top: 60,
//         bottom: 30,
//         left: 20,
//         right: 20,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary,
//             AppColors.secondary,
//           ],
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Barre d'actions
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 onPressed: _refreshData,
//                 icon: _refreshing
//                     ? const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//                     : const Icon(Icons.refresh, color: Colors.white),
//                 tooltip: 'Rafraîchir',
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   userTypeText,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//               IconButton(
//                 onPressed: _logout,
//                 icon: const Icon(Icons.logout, color: Colors.white),
//                 tooltip: 'Déconnexion',
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           // Avatar utilisateur
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(40),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Center(
//               child: Text(
//                 initials,
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Nom et email
//           Text(
//             _currentUser?.fullName ?? 'Utilisateur',
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//             textAlign: TextAlign.center,
//           ),
//
//           const SizedBox(height: 8),
//
//           Text(
//             _currentUser?.email ?? '',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.white.withOpacity(0.9),
//             ),
//             textAlign: TextAlign.center,
//           ),
//
//           const SizedBox(height: 20),
//
//           // Statistiques rapides
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildHeaderStatItem(_userStats['demandes']!, 'Demandes', Icons.request_page),
//               _buildHeaderStatItem(_userStats['contrats']!, 'Contrats', Icons.contrast),
//               _buildHeaderStatItem(_userStats['paiements']!, 'Paiements', Icons.payment),
//               _buildHeaderStatItem(_userStats['biens_loues']!, 'Biens Loués', Icons.home),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeaderStatItem(int value, String label, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, size: 22, color: Colors.white),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value.toString(),
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.white.withOpacity(0.8),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFeatureCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(15),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               const SizedBox(height: 15),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.dark,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 description,
//                 style: TextStyle(
//                   color: AppColors.greyMedium,
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoItem(String label, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: AppColors.primary, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     color: AppColors.greyDark,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value.isNotEmpty ? value : 'Non renseigné',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showComingSoon(String feature) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$feature - Bientôt disponible'),
//         backgroundColor: AppColors.primary,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
//
//   List<Map<String, dynamic>> _getFeatures() {
//     final userType = _currentUser?.type ?? 'LOCATAIRE';
//
//     // On retourne uniquement les fonctionnalités pour locataires
//     return [
//       {
//         'title': 'Mes Contrats',
//         'description': 'Consultez et gérez vos contrats de location',
//         'icon': Icons.contrast,
//         'color': AppColors.primary,
//         'route': '/contrats',
//       },
//       {
//         'title': 'Mes Paiements',
//         'description': 'Suivez vos paiements et téléchargez les quittances',
//         'icon': Icons.payment,
//         'color': Colors.green,
//         'route': '/paiements',
//       },
//       {
//         'title': 'Mes Demandes',
//         'description': 'Consultez vos demandes de location',
//         'icon': Icons.request_page,
//         'color': Colors.orange,
//         'route': '/demandes',
//       },
//       {
//         'title': 'Mes Biens',
//         'description': 'Consulter vos biens',
//         'icon': Icons.house,
//         'color': Colors.blue,
//         'route': '/biens',
//       },
//     ];
//   }
//
//   void _navigateToFeature(String route) {
//     // Utilisez les routes que vous avez déjà implémentées
//     switch (route) {
//       case '/contrats':
//         Navigator.pushNamed(context, '/contrats');
//         break;
//       case '/paiements':
//         Navigator.pushNamed(context, '/paiements');
//         break;
//       case '/demandes':
//         Navigator.pushNamed(context, '/demandes');
//         break;
//       case '/biens':
//         Navigator.pushNamed(context, '/biens');
//         break;
//       default:
//         _showComingSoon('Cette fonctionnalité');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: AppColors.primary),
//               const SizedBox(height: 20),
//               Text(
//                 'Chargement de votre espace...',
//                 style: TextStyle(
//                   color: AppColors.greyDark,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     final features = _getFeatures();
//
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: _refreshData,
//         color: AppColors.primary,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Column(
//             children: [
//               // Header avec informations utilisateur
//               _buildHeader(),
//
//               // Fonctionnalités principales
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 20),
//                     Text(
//                       'Fonctionnalités',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.dark,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Accédez rapidement à vos services',
//                       style: TextStyle(
//                         color: AppColors.greyDark,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 15,
//                         mainAxisSpacing: 15,
//                         childAspectRatio: 1.2,
//                       ),
//                       itemCount: features.length,
//                       itemBuilder: (context, index) {
//                         final feature = features[index];
//                         return _buildFeatureCard(
//                           feature['title'],
//                           feature['description'],
//                           feature['icon'],
//                           feature['color'],
//                               () {
//                             _navigateToFeature(feature['route']);
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Informations personnelles
//               Container(
//                 margin: const EdgeInsets.all(20),
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.person_outline, color: AppColors.primary, size: 24),
//                         const SizedBox(width: 10),
//                         Text(
//                           'Informations personnelles',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.dark,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     _buildInfoItem('Téléphone', _currentUser?.phone ?? '', Icons.phone),
//                     const SizedBox(height: 12),
//                     _buildInfoItem('Adresse', _currentUser?.adresse ?? '', Icons.location_on),
//                     const SizedBox(height: 12),
//                     _buildInfoItem('Type de compte', 'Locataire', Icons.badge),
//
//                     if (_currentUser?.phone?.isEmpty ?? true)
//                       Container(
//                         margin: const EdgeInsets.only(top: 20),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.orange.withOpacity(0.3)),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.info_outline, color: Colors.orange, size: 20),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 'Complétez votre profil pour une meilleure expérience',
//                                 style: TextStyle(
//                                   color: Colors.orange,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//
//       // Navigation rapide - VERSION SIMPLIFIÉE ET FONCTIONNELLE
//       bottomNavigationBar: Container(
//         height: 70,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//           color: Colors.white,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // Accueil - reste sur la page actuelle
//             _buildNavItem(
//               Icons.home_filled,
//               'Accueil',
//               true, // Toujours actif sur cette page
//                   () {
//                 // Déjà sur la page d'accueil, donc on ne fait rien
//                 // ou on peut rafraîchir
//                 _refreshData();
//               },
//             ),
//
//             // Recherche - navigue vers la page de recherche
//             _buildNavItem(
//               Icons.search,
//               'Rechercher',
//               false,
//                   () {
//                 Navigator.pushNamed(context, '/recherche');
//               },
//             ),
//
//             // Notifications - navigue vers la page des notifications
//             _buildNavItem(
//               Icons.notifications,
//               'Notifications',
//               false,
//                   () {
//                 Navigator.pushNamed(context, '/notifications');
//               },
//             ),
//
//             // Profil - navigue vers la page de profil
//             _buildNavItem(
//               Icons.person,
//               'Profil',
//               false,
//                   () {
//                 Navigator.pushNamed(context, '/profil');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//     Widget _buildNavItem(IconData icon, String label, bool active, VoidCallback onTap) {
//       return GestureDetector(
//         onTap: onTap,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: active ? AppColors.primary : AppColors.greyMedium,
//               size: 24,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: active ? AppColors.primary : AppColors.greyMedium,
//               ),
//             ),
//           ],
//         ),
//       );
//     }