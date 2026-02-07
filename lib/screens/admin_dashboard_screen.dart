// // lib/screens/admin/admin_dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});
//
//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }
//
// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   final String baseUrl = 'http://localhost:8000';
//   bool _isLoading = true;
//   String _error = '';
//
//   // Statistiques réelles
//   int _totalBiens = 0;
//   int _totalDemandes = 0;
//   int _totalReclamations = 0;
//   int _totalContrats = 0;
//   int _demandesEnAttente = 0;
//   int _biensEnAttente = 0;
//   int _reclamationsEnAttente = 0;
//   int _paiementsEnRetard = 0;
//
//   // Données pour graphiques
//   List<Map<String, dynamic>> _demandesStats = [];
//   List<Map<String, dynamic>> _reclamationsStats = [];
//   List<Map<String, dynamic>> _contratsStats = [];
//
//   // Listes détaillées
//   List<dynamic> _demandesList = [];
//   List<dynamic> _reclamationsList = [];
//   List<dynamic> _biensList = [];
//   List<dynamic> _paiementsList = [];
//
//   // Index pour la navigation
//   int _selectedIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDashboardData();
//   }
//
//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }
//
//   Future<void> _loadDashboardData() async {
//     setState(() {
//       _isLoading = true;
//       _error = '';
//     });
//
//     try {
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Non authentifié');
//       }
//
//       final headers = {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       };
//
//       // Charger toutes les données en parallèle
//       await Future.wait([
//         _loadAllStats(headers),
//         _loadDemandesStats(headers),
//         _loadReclamationsStats(headers),
//         _loadContratsStats(headers),
//       ]);
//
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('❌ Erreur: $e');
//       setState(() {
//         _error = 'Erreur de chargement: $e';
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _loadAllStats(Map<String, String> headers) async {
//     try {
//       // Biens totaux
//       final biensResponse = await http.get(
//         Uri.parse('$baseUrl/api/v1/biens'),
//         headers: headers,
//       );
//       if (biensResponse.statusCode == 200) {
//         final List<dynamic> biens = jsonDecode(biensResponse.body);
//         _totalBiens = biens.length;
//       }
//
//       // Biens en attente
//       final biensAttenteResponse = await http.get(
//         Uri.parse('$baseUrl/api/v1/biens/stats/en-attente'),
//         headers: headers,
//       );
//       if (biensAttenteResponse.statusCode == 200) {
//         final data = jsonDecode(biensAttenteResponse.body);
//         _biensEnAttente = data['count'] ?? 0;
//       }
//
//       // Demandes totales
//       final demandesResponse = await http.get(
//         Uri.parse('$baseUrl/api/v1/demandes-location'),
//         headers: headers,
//       );
//       if (demandesResponse.statusCode == 200) {
//         final List<dynamic> demandes = jsonDecode(demandesResponse.body);
//         _totalDemandes = demandes.length;
//       }
//
//       // Demandes en attente
//       final demandesAttenteResponse = await http.get(
//         Uri.parse('$baseUrl/api/v1/demandes-location/stats/en-attente'),
//         headers: headers,
//       );
//       if (demandesAttenteResponse.statusCode == 200) {
//         final data = jsonDecode(demandesAttenteResponse.body);
//         _demandesEnAttente = data['count'] ?? 0;
//       }
//
//       // Réclamations totales
//       final reclamationsResponse = await http.get(
//         Uri.parse('$baseUrl/api/v1/reclamations'),
//         headers: headers,
//       );
//       if (reclamationsResponse.statusCode == 200) {
//         final data = jsonDecode(reclamationsResponse.body);
//         final List<dynamic> reclamations = data['data'] ?? [];
//         _totalReclamations = reclamations.length;
//       }
//
//       // Réclamations en attente
//       final reclamationsAttenteResponse = await http.get(
//         Uri.parse('$baseUrl/api/v1/reclamations/filtrer?statut=EN_ATTENTE'),
//         headers: headers,
//       );
//       if (reclamationsAttenteResponse.statusCode == 200) {
//         final data = jsonDecode(reclamationsAttenteResponse.body);
//         final List<dynamic> reclamations = data['data'] ?? [];
//         _reclamationsEnAttente = reclamations.length;
//       }
//
//       // Contrats totaux
//       final contratsResponse = await http.get(
//         Uri.parse('$baseUrl/api/v1/contrats'),
//         headers: headers,
//       );
//       if (contratsResponse.statusCode == 200) {
//         final List<dynamic> contrats = jsonDecode(contratsResponse.body);
//         _totalContrats = contrats.length;
//       }
//
//       // Paiements en retard
//       final paiementsRetardResponse = await http.get(
//         Uri.parse('$baseUrl/payments/en-retard'),
//         headers: headers,
//       );
//       if (paiementsRetardResponse.statusCode == 200) {
//         final List<dynamic> paiements = jsonDecode(paiementsRetardResponse.body);
//         _paiementsEnRetard = paiements.length;
//       }
//
//     } catch (e) {
//       print('⚠️ Erreur stats: $e');
//     }
//   }
//
//   Future<void> _loadDemandesStats(Map<String, String> headers) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/v1/demandes-location'),
//         headers: headers,
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//
//         // Compter par statut
//         final Map<String, int> stats = {};
//         for (var demande in data) {
//           final statut = demande['statut'] ?? 'INCONNU';
//           stats[statut] = (stats[statut] ?? 0) + 1;
//         }
//
//         // Convertir pour l'affichage
//         _demandesStats = stats.entries.map((entry) {
//           return {
//             'statut': entry.key,
//             'count': entry.value,
//             'color': _getColorForDemandeStatut(entry.key),
//           };
//         }).toList();
//
//         _demandesList = data;
//       }
//     } catch (e) {
//       print('⚠️ Erreur stats demandes: $e');
//     }
//   }
//
//   Future<void> _loadReclamationsStats(Map<String, String> headers) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/v1/reclamations'),
//         headers: headers,
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> reclamations = data['data'] ?? [];
//
//         // Compter par statut
//         final Map<String, int> stats = {};
//         for (var reclamation in reclamations) {
//           final statut = reclamation['statut'] ?? 'INCONNU';
//           stats[statut] = (stats[statut] ?? 0) + 1;
//         }
//
//         _reclamationsStats = stats.entries.map((entry) {
//           return {
//             'statut': entry.key,
//             'count': entry.value,
//             'color': _getColorForReclamationStatut(entry.key),
//           };
//         }).toList();
//
//         _reclamationsList = reclamations;
//       }
//     } catch (e) {
//       print('⚠️ Erreur stats réclamations: $e');
//     }
//   }
//
//   Future<void> _loadContratsStats(Map<String, String> headers) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/v1/contrats'),
//         headers: headers,
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//
//         // Compter par statut
//         final Map<String, int> stats = {};
//         for (var contrat in data) {
//           final statut = contrat['statut'] ?? 'INCONNU';
//           stats[statut] = (stats[statut] ?? 0) + 1;
//         }
//
//         _contratsStats = stats.entries.map((entry) {
//           return {
//             'statut': entry.key,
//             'count': entry.value,
//             'color': _getColorForContratStatut(entry.key),
//           };
//         }).toList();
//       }
//     } catch (e) {
//       print('⚠️ Erreur stats contrats: $e');
//     }
//   }
//
//   Color _getColorForDemandeStatut(String statut) {
//     switch (statut.toUpperCase()) {
//       case 'EN_ATTENTE':
//         return Colors.orange;
//       case 'ACCEPTEE':
//       case 'ACCEPTÉE':
//         return Colors.green;
//       case 'REFUSEE':
//       case 'REFUSÉE':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   Color _getColorForReclamationStatut(String statut) {
//     switch (statut.toUpperCase()) {
//       case 'NOUVELLE':
//       case 'EN_ATTENTE':
//         return Colors.blue;
//       case 'EN_COURS':
//         return Colors.orange;
//       case 'RÉSOLUE':
//       case 'RESOLUE':
//         return Colors.green;
//       case 'FERMÉE':
//       case 'FERMEE':
//         return Colors.grey;
//       default:
//         return Colors.purple;
//     }
//   }
//
//   Color _getColorForContratStatut(String statut) {
//     switch (statut.toUpperCase()) {
//       case 'ACTIF':
//         return Colors.green;
//       case 'EXPIRÉ':
//       case 'EXPIRE':
//         return Colors.orange;
//       case 'RÉSILIÉ':
//       case 'RESILIE':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   // Navigation entre les sections
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   // Widgets pour chaque section
//   Widget _buildDashboardSection() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // En-tête
//           const Text(
//             'Tableau de bord Administrateur',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Aperçu global du système',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // Cartes de statistiques
//           GridView.count(
//             crossAxisCount: 4,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             mainAxisSpacing: 16,
//             crossAxisSpacing: 16,
//             childAspectRatio: 1.5,
//             children: [
//               _buildStatCard(
//                 title: 'Biens immobiliers',
//                 value: _totalBiens,
//                 icon: Icons.apartment,
//                 color: Colors.blue,
//                 subtitle: '$_biensEnAttente en attente',
//               ),
//               _buildStatCard(
//                 title: 'Demandes de location',
//                 value: _totalDemandes,
//                 icon: Icons.request_page,
//                 color: Colors.orange,
//                 subtitle: '$_demandesEnAttente en attente',
//               ),
//               _buildStatCard(
//                 title: 'Réclamations',
//                 value: _totalReclamations,
//                 icon: Icons.report_problem,
//                 color: Colors.red,
//                 subtitle: '$_reclamationsEnAttente en attente',
//               ),
//               _buildStatCard(
//                 title: 'Contrats actifs',
//                 value: _totalContrats,
//                 icon: Icons.assignment,
//                 color: Colors.green,
//                 subtitle: '$_paiementsEnRetard paiements retard',
//               ),
//             ],
//           ),
//           const SizedBox(height: 32),
//
//           // Graphiques (en utilisant des cartes avec listes)
//           const Text(
//             'Statistiques détaillées',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey,
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Demandes par statut
//           _buildStatsCard(
//             title: 'Demandes par statut',
//             data: _demandesStats,
//             icon: Icons.bar_chart,
//             color: Colors.blue,
//           ),
//           const SizedBox(height: 16),
//
//           // Réclamations par statut
//           _buildStatsCard(
//             title: 'Réclamations par statut',
//             data: _reclamationsStats,
//             icon: Icons.pie_chart,
//             color: Colors.orange,
//           ),
//           const SizedBox(height: 16),
//
//           // Contrats par statut
//           _buildStatsCard(
//             title: 'Contrats par statut',
//             data: _contratsStats,
//             icon: Icons.show_chart,
//             color: Colors.green,
//           ),
//           const SizedBox(height: 32),
//
//           // Actions rapides
//           const Text(
//             'Actions rapides',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildQuickActions(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDemandesSection() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Gestion des demandes',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueGrey,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: _loadDashboardData,
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Actualiser'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//
//           // Filtres
//           _buildFilterChips(),
//           const SizedBox(height: 16),
//
//           // Liste des demandes
//           if (_demandesList.isEmpty)
//             const Center(
//               child: Column(
//                 children: [
//                   Icon(Icons.inbox, size: 60, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'Aucune demande trouvée',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             )
//           else
//             ..._demandesList.map((demande) {
//               return _buildDemandeCard(demande);
//             }).toList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReclamationsSection() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Gestion des réclamations',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey,
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           if (_reclamationsList.isEmpty)
//             const Center(
//               child: Column(
//                 children: [
//                   Icon(Icons.report_off, size: 60, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'Aucune réclamation trouvée',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             )
//           else
//             ..._reclamationsList.map((reclamation) {
//               return _buildReclamationCard(reclamation);
//             }).toList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildParametresSection() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Paramètres système',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey,
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Configuration générale',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildSettingItem(
//                     title: 'Notifications par email',
//                     subtitle: 'Activer/désactiver les notifications',
//                     icon: Icons.email,
//                     value: true,
//                   ),
//                   _buildSettingItem(
//                     title: 'Notifications push',
//                     subtitle: 'Recevoir des notifications push',
//                     icon: Icons.notifications,
//                     value: true,
//                   ),
//                   _buildSettingItem(
//                     title: 'Mode maintenance',
//                     subtitle: 'Mettre le système en maintenance',
//                     icon: Icons.engineering,
//                     value: false,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Sécurité',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildSettingItem(
//                     title: 'Authentification à deux facteurs',
//                     subtitle: 'Exiger 2FA pour les administrateurs',
//                     icon: Icons.security,
//                     value: true,
//                   ),
//                   _buildSettingItem(
//                     title: 'Journalisation des activités',
//                     subtitle: 'Conserver les logs système',
//                     icon: Icons.history,
//                     value: true,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard({
//     required String title,
//     required int value,
//     required IconData icon,
//     required Color color,
//     required String subtitle,
//   }) {
//     return SizedBox( // <-- COMMENCEZ par SizedBox
//       width: 110,
//       height: 110,
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: color, size: 18),
//               const SizedBox(height: 4),
//               Text(
//                 value.toString(),
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 title.split(' ')[0], // <-- Prend seulement le premier mot
//                 style: const TextStyle(
//                   fontSize: 10,
//                   color: Colors.grey,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatsCard({
//     required String title,
//     required List<Map<String, dynamic>> data,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: color),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (data.isEmpty)
//               const Center(
//                 child: Text(
//                   'Aucune donnée disponible',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               )
//             else
//               Column(
//                 children: data.map((item) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 12,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             color: item['color'],
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             _formatStatut(item['statut']),
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ),
//                         Text(
//                           item['count'].toString(),
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickActions() {
//     final actions = [
//       {
//         'title': 'Valider un bien',
//         'icon': Icons.check_circle,
//         'color': Colors.green,
//         'route': '/admin/biens',
//       },
//       {
//         'title': 'Traiter demande',
//         'icon': Icons.task_alt,
//         'color': Colors.blue,
//         'route': '/admin/demandes',
//       },
//       {
//         'title': 'Gérer réclamation',
//         'icon': Icons.support_agent,
//         'color': Colors.orange,
//         'route': '/admin/reclamations',
//       },
//       {
//         'title': 'Voir rapports',
//         'icon': Icons.assessment,
//         'color': Colors.purple,
//         'route': '/admin/rapports',
//       },
//     ];
//
//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       mainAxisSpacing: 16,
//       crossAxisSpacing: 16,
//       childAspectRatio: 1.5,
//       children: actions.map((action) {
//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(12),
//             onTap: () {
//               // TODO: Naviguer vers la route
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     action['icon'] as IconData,
//                     color: action['color'] as Color,
//                     size: 32,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     action['title'] as String,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildDemandeCard(Map<String, dynamic> demande) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Demande #${demande['id']}',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _getColorForDemandeStatut(demande['statut'])
//                         .withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     _formatStatut(demande['statut']),
//                     style: TextStyle(
//                       color: _getColorForDemandeStatut(demande['statut']),
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (demande['bienReference'] != null)
//               Text(
//                 'Bien: ${demande['bienReference']}',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             if (demande['message'] != null)
//               Text(
//                 'Message: ${demande['message']}',
//                 style: const TextStyle(color: Colors.grey),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             const SizedBox(height: 12),
//             if (demande['statut'] == 'EN_ATTENTE')
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () => _traiterDemande(demande['id'], 'accepter'),
//                       icon: const Icon(Icons.check, size: 16),
//                       label: const Text('Accepter'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: () => _traiterDemande(demande['id'], 'refuser'),
//                       icon: const Icon(Icons.close, size: 16),
//                       label: const Text('Refuser'),
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Colors.red),
//                         foregroundColor: Colors.red,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildReclamationCard(Map<String, dynamic> reclamation) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Réclamation #${reclamation['id']}',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _getColorForReclamationStatut(reclamation['statut'])
//                         .withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     _formatStatut(reclamation['statut']),
//                     style: TextStyle(
//                       color: _getColorForReclamationStatut(reclamation['statut']),
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (reclamation['titre'] != null)
//               Text(
//                 reclamation['titre'],
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             if (reclamation['description'] != null)
//               Text(
//                 reclamation['description'],
//                 style: const TextStyle(color: Colors.grey),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             const SizedBox(height: 12),
//             if (reclamation['statut'] == 'EN_ATTENTE')
//               ElevatedButton.icon(
//                 onPressed: () => _prendreEnChargeReclamation(reclamation['id']),
//                 icon: const Icon(Icons.play_arrow, size: 16),
//                 label: const Text('Prendre en charge'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilterChips() {
//     final filters = ['Toutes', 'En attente', 'Acceptées', 'Refusées'];
//
//     return Wrap(
//       spacing: 8,
//       children: filters.map((filter) {
//         return FilterChip(
//           label: Text(filter),
//           selected: filter == 'Toutes',
//           onSelected: (selected) {
//             // TODO: Filtrer la liste
//           },
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildSettingItem({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required bool value,
//   }) {
//     return SwitchListTile(
//       title: Text(title),
//       subtitle: Text(subtitle),
//       secondary: Icon(icon),
//       value: value,
//       onChanged: (newValue) {
//         // TODO: Sauvegarder le paramètre
//       },
//     );
//   }
//
//   String _formatStatut(String statut) {
//     return statut
//         .replaceAll('_', ' ')
//         .toLowerCase()
//         .split(' ')
//         .map((word) => word[0].toUpperCase() + word.substring(1))
//         .join(' ');
//   }
//
//   Future<void> _traiterDemande(int id, String action) async {
//     try {
//       final token = await _getToken();
//       final endpoint = action == 'accepter'
//           ? '/api/v1/demandes-location/$id/accepter'
//           : '/api/v1/demandes-location/$id/refuser';
//
//       final response = await http.patch(
//         Uri.parse('$baseUrl$endpoint'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: action == 'refuser'
//             ? jsonEncode({'motifRefus': 'Refusé par l\'administrateur'})
//             : null,
//       );
//
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Demande ${action == 'accepter' ? 'acceptée' : 'refusée'}'),
//             backgroundColor: action == 'accepter' ? Colors.green : Colors.red,
//           ),
//         );
//         await _loadDashboardData();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erreur: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> _prendreEnChargeReclamation(int id) async {
//     try {
//       final token = await _getToken();
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/v1/reclamations/$id/prendre-en-charge'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'commentaire': 'Pris en charge'}),
//       );
//
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Réclamation prise en charge'),
//             backgroundColor: Colors.blue,
//           ),
//         );
//         await _loadDashboardData();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erreur: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Administration'),
//         backgroundColor: Colors.blueGrey.shade800,
//         foregroundColor: Colors.white,
//         elevation: 4,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _isLoading ? null : _loadDashboardData,
//             tooltip: 'Actualiser',
//           ),
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               // TODO: Notifications
//             },
//             tooltip: 'Notifications',
//           ),
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () {
//               // TODO: Profil
//             },
//             tooltip: 'Profil',
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _error.isNotEmpty
//           ? Center(child: Text(_error))
//           : IndexedStack(
//         index: _selectedIndex,
//         children: [
//           _buildDashboardSection(),
//           _buildDemandesSection(),
//           _buildReclamationsSection(),
//           _buildParametresSection(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: Colors.blueGrey.shade800,
//         unselectedItemColor: Colors.grey.shade600,
//         selectedLabelStyle: const TextStyle(fontSize: 12),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: 'Dashboard',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.request_page),
//             label: 'Demandes',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.report_problem),
//             label: 'Réclamations',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Paramètres',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawer() {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           UserAccountsDrawerHeader(
//             accountName: const Text('Administrateur'),
//             accountEmail: const Text('admin@system.com'),
//             currentAccountPicture: const CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(Icons.admin_panel_settings, color: Colors.blueGrey),
//             ),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey.shade800,
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.dashboard),
//             title: const Text('Tableau de bord'),
//             selected: _selectedIndex == 0,
//             onTap: () {
//               Navigator.pop(context);
//               _onItemTapped(0);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.apartment),
//             title: const Text('Gestion des biens'),
//             onTap: () {
//               // TODO: Naviguer vers biens
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.request_page),
//             title: const Text('Demandes de location'),
//             selected: _selectedIndex == 1,
//             onTap: () {
//               Navigator.pop(context);
//               _onItemTapped(1);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.assignment),
//             title: const Text('Contrats'),
//             onTap: () {
//               // TODO: Naviguer vers contrats
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.report_problem),
//             title: const Text('Réclamations'),
//             selected: _selectedIndex == 2,
//             onTap: () {
//               Navigator.pop(context);
//               _onItemTapped(2);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.payment),
//             title: const Text('Paiements'),
//             onTap: () {
//               // TODO: Naviguer vers paiements
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.people),
//             title: const Text('Utilisateurs'),
//             onTap: () {
//               // TODO: Naviguer vers utilisateurs
//             },
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Paramètres'),
//             selected: _selectedIndex == 3,
//             onTap: () {
//               Navigator.pop(context);
//               _onItemTapped(3);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.help_outline),
//             title: const Text('Aide & Support'),
//             onTap: () {
//               // TODO: Aide
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Déconnexion'),
//             onTap: () async {
//               final prefs = await SharedPreferences.getInstance();
//               await prefs.remove('auth_token');
//               Navigator.pushReplacementNamed(context, '/login');
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'bien_gestion_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final String baseUrl = 'http://localhost:8000';
  bool _isLoading = true;
  String _error = '';

  // Statistiques réelles
  int _totalBiens = 0;
  int _totalDemandes = 0;
  int _totalReclamations = 0;
  int _totalContrats = 0;
  int _totalUtilisateurs = 0;
  int _demandesEnAttente = 0;
  int _biensEnAttente = 0;
  int _reclamationsEnAttente = 0;
  int _paiementsEnRetard = 0;

  // Données pour graphiques
  List<Map<String, dynamic>> _demandesStats = [];
  List<Map<String, dynamic>> _reclamationsStats = [];
  List<Map<String, dynamic>> _contratsStats = [];
  List<Map<String, dynamic>> _usersStats = [];

  // Listes détaillées
  List<dynamic> _demandesList = [];
  List<dynamic> _reclamationsList = [];
  List<dynamic> _biensList = [];
  List<dynamic> _paiementsList = [];
  List<dynamic> _usersList = [];

  // Index pour la navigation
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Charger toutes les données en parallèle
      await Future.wait([
        _loadAllStats(headers),
        _loadDemandesStats(headers),
        _loadReclamationsStats(headers),
        _loadContratsStats(headers),
        _loadUsersStats(headers),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur: $e');
      setState(() {
        _error = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllStats(Map<String, String> headers) async {
    try {
      // Biens totaux
      final biensResponse = await http.get(
        Uri.parse('$baseUrl/api/v1/biens'),
        headers: headers,
      );
      if (biensResponse.statusCode == 200) {
        final List<dynamic> biens = jsonDecode(biensResponse.body);
        _totalBiens = biens.length;
      }

      // Biens en attente
      final biensAttenteResponse = await http.get(
        Uri.parse('$baseUrl/api/v1/biens/stats/en-attente'),
        headers: headers,
      );
      if (biensAttenteResponse.statusCode == 200) {
        final data = jsonDecode(biensAttenteResponse.body);
        _biensEnAttente = data['count'] ?? 0;
      }

      // Demandes totales
      final demandesResponse = await http.get(
        Uri.parse('$baseUrl/api/v1/demandes-location'),
        headers: headers,
      );
      if (demandesResponse.statusCode == 200) {
        final List<dynamic> demandes = jsonDecode(demandesResponse.body);
        _totalDemandes = demandes.length;
      }

      // Demandes en attente
      final demandesAttenteResponse = await http.get(
        Uri.parse('$baseUrl/api/v1/demandes-location/stats/en-attente'),
        headers: headers,
      );
      if (demandesAttenteResponse.statusCode == 200) {
        final data = jsonDecode(demandesAttenteResponse.body);
        _demandesEnAttente = data['count'] ?? 0;
      }

      // Réclamations totales
      final reclamationsResponse = await http.get(
        Uri.parse('$baseUrl/api/v1/reclamations'),
        headers: headers,
      );
      if (reclamationsResponse.statusCode == 200) {
        final data = jsonDecode(reclamationsResponse.body);
        final List<dynamic> reclamations = data['data'] ?? [];
        _totalReclamations = reclamations.length;
      }

      // Réclamations en attente
      final reclamationsAttenteResponse = await http.get(
        Uri.parse('$baseUrl/api/v1/reclamations/filtrer?statut=EN_ATTENTE'),
        headers: headers,
      );
      if (reclamationsAttenteResponse.statusCode == 200) {
        final data = jsonDecode(reclamationsAttenteResponse.body);
        final List<dynamic> reclamations = data['data'] ?? [];
        _reclamationsEnAttente = reclamations.length;
      }

      // Contrats totaux
      final contratsResponse = await http.get(
        Uri.parse('$baseUrl/api/v1/contrats'),
        headers: headers,
      );
      if (contratsResponse.statusCode == 200) {
        final List<dynamic> contrats = jsonDecode(contratsResponse.body);
        _totalContrats = contrats.length;
      }

      // Paiements en retard
      final paiementsRetardResponse = await http.get(
        Uri.parse('$baseUrl/payments/en-retard'),
        headers: headers,
      );
      if (paiementsRetardResponse.statusCode == 200) {
        final List<dynamic> paiements = jsonDecode(paiementsRetardResponse.body);
        _paiementsEnRetard = paiements.length;
      }

      // Utilisateurs
      final usersResponse = await http.get(
        Uri.parse('$baseUrl/api/personnes'),
        headers: headers,
      );
      if (usersResponse.statusCode == 200) {
        final List<dynamic> users = jsonDecode(usersResponse.body);
        _totalUtilisateurs = users.length;
        _usersList = users;
      }

    } catch (e) {
      print('⚠️ Erreur stats: $e');
    }
  }

  Future<void> _loadDemandesStats(Map<String, String> headers) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/demandes-location'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Compter par statut
        final Map<String, int> stats = {};
        for (var demande in data) {
          final statut = demande['statut'] ?? 'INCONNU';
          stats[statut] = (stats[statut] ?? 0) + 1;
        }

        // Convertir pour l'affichage
        _demandesStats = stats.entries.map((entry) {
          return {
            'statut': entry.key,
            'count': entry.value,
            'color': _getColorForDemandeStatut(entry.key),
          };
        }).toList();

        _demandesList = data;
      }
    } catch (e) {
      print('⚠️ Erreur stats demandes: $e');
    }
  }

  Future<void> _loadReclamationsStats(Map<String, String> headers) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/reclamations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> reclamations = data['data'] ?? [];

        // Compter par statut
        final Map<String, int> stats = {};
        for (var reclamation in reclamations) {
          final statut = reclamation['statut'] ?? 'INCONNU';
          stats[statut] = (stats[statut] ?? 0) + 1;
        }

        _reclamationsStats = stats.entries.map((entry) {
          return {
            'statut': entry.key,
            'count': entry.value,
            'color': _getColorForReclamationStatut(entry.key),
          };
        }).toList();

        _reclamationsList = reclamations;
      }
    } catch (e) {
      print('⚠️ Erreur stats réclamations: $e');
    }
  }

  Future<void> _loadContratsStats(Map<String, String> headers) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/contrats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Compter par statut
        final Map<String, int> stats = {};
        for (var contrat in data) {
          final statut = contrat['statut'] ?? 'INCONNU';
          stats[statut] = (stats[statut] ?? 0) + 1;
        }

        _contratsStats = stats.entries.map((entry) {
          return {
            'statut': entry.key,
            'count': entry.value,
            'color': _getColorForContratStatut(entry.key),
          };
        }).toList();
      }
    } catch (e) {
      print('⚠️ Erreur stats contrats: $e');
    }
  }

  Future<void> _loadUsersStats(Map<String, String> headers) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Compter par type
        final Map<String, int> stats = {};
        for (var user in data) {
          final type = user['type'] ?? user['role'] ?? 'INCONNU';
          stats[type] = (stats[type] ?? 0) + 1;
        }

        _usersStats = stats.entries.map((entry) {
          return {
            'type': entry.key,
            'count': entry.value,
            'color': _getColorForUserType(entry.key),
          };
        }).toList();
      }
    } catch (e) {
      print('⚠️ Erreur stats utilisateurs: $e');
    }
  }

  Color _getColorForDemandeStatut(String statut) {
    switch (statut.toUpperCase()) {
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'ACCEPTEE':
      case 'ACCEPTÉE':
        return Colors.green;
      case 'REFUSEE':
      case 'REFUSÉE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getColorForReclamationStatut(String statut) {
    switch (statut.toUpperCase()) {
      case 'NOUVELLE':
      case 'EN_ATTENTE':
        return Colors.blue;
      case 'EN_COURS':
        return Colors.orange;
      case 'RÉSOLUE':
      case 'RESOLUE':
        return Colors.green;
      case 'FERMÉE':
      case 'FERMEE':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  Color _getColorForContratStatut(String statut) {
    switch (statut.toUpperCase()) {
      case 'ACTIF':
        return Colors.green;
      case 'EXPIRÉ':
      case 'EXPIRE':
        return Colors.orange;
      case 'RÉSILIÉ':
      case 'RESILIE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getColorForUserType(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN':
        return Colors.deepPurple;
      case 'PROPRIETAIRE':
        return Colors.blue;
      case 'LOCATAIRE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Navigation entre les sections
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Widgets pour chaque section
  Widget _buildDashboardSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          const Text(
            'Tableau de bord Administrateur',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aperçu global du système',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Cartes de statistiques
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Biens immobiliers',
                value: _totalBiens,
                icon: Icons.apartment,
                color: Colors.blue,
                subtitle: '$_biensEnAttente en attente',
              ),
              _buildStatCard(
                title: 'Demandes location',
                value: _totalDemandes,
                icon: Icons.request_page,
                color: Colors.orange,
                subtitle: '$_demandesEnAttente en attente',
              ),
              _buildStatCard(
                title: 'Réclamations',
                value: _totalReclamations,
                icon: Icons.report_problem,
                color: Colors.red,
                subtitle: '$_reclamationsEnAttente en attente',
              ),
              _buildStatCard(
                title: 'Utilisateurs',
                value: _totalUtilisateurs,
                icon: Icons.people,
                color: Colors.green,
                subtitle: '$_totalContrats contrats',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Graphiques
          const Text(
            'Statistiques détaillées',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),

          // Demandes par statut
          _buildStatsCard(
            title: 'Demandes par statut',
            data: _demandesStats,
            icon: Icons.bar_chart,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),

          // Réclamations par statut
          _buildStatsCard(
            title: 'Réclamations par statut',
            data: _reclamationsStats,
            icon: Icons.pie_chart,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),


          // Actions rapides
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildDemandesSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des demandes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualiser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filtres
          _buildDemandeFilterChips(),
          const SizedBox(height: 16),

          // Liste des demandes
          if (_demandesList.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune demande trouvée',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ..._demandesList.map((demande) {
              return _buildDemandeCard(demande);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildReclamationsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des réclamations',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualiser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filtres
          _buildReclamationFilterChips(),
          const SizedBox(height: 16),

          if (_reclamationsList.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.report_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune réclamation trouvée',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ..._reclamationsList.map((reclamation) {
              return _buildReclamationCard(reclamation);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildRapportsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rapports et Statistiques',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyse complète des performances du système',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Statistiques principales
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Indicateurs Clés de Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildKPIItem('Taux de conversion demandes', '${(_demandesEnAttente > 0 ? (_totalDemandes - _demandesEnAttente) / _totalDemandes * 100 : 0).toStringAsFixed(1)}%', Icons.trending_up, Colors.green),
                  _buildKPIItem('Temps moyen traitement réclamation', '24h', Icons.timer, Colors.orange),
                  _buildKPIItem('Taux de résolution réclamations', '${(_reclamationsEnAttente > 0 ? (_totalReclamations - _reclamationsEnAttente) / _totalReclamations * 100 : 0).toStringAsFixed(1)}%', Icons.check_circle, Colors.blue),
                  _buildKPIItem('Taux d\'occupation biens',
                      '${_totalBiens > 0 ? (_biensLouesCount / _totalBiens * 100).toStringAsFixed(1) : 0}%',
                      Icons.home_work, Colors.purple),                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Distribution par type
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distribution par Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDistributionRow('Utilisateurs', _totalUtilisateurs, Colors.blue),
                  _buildDistributionRow('Biens immobiliers', _totalBiens, Colors.green),
                  _buildDistributionRow('Contrats actifs', _totalContrats, Colors.orange),
                  _buildDistributionRow('Paiements en retard', _paiementsEnRetard, Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Activité récente
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activité Récente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActivityItem('Nouvelles demandes', '$_demandesEnAttente en attente', Icons.request_page, Colors.blue),
                  _buildActivityItem('Réclamations ouvertes', '$_reclamationsEnAttente non traitées', Icons.report_problem, Colors.orange),
                  _buildActivityItem('Biens à valider', '$_biensEnAttente en attente', Icons.apartment, Colors.green),
                  _buildActivityItem('Paiements en retard', '$_paiementsEnRetard à suivre', Icons.payment, Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Générer rapport PDF
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exporter PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loadDashboardData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Méthodes auxiliaires pour la section rapports
  Widget _buildKPIItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title.split(' ')[0],
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required List<Map<String, dynamic>> data,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (data.isEmpty)
              const Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: data.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item['color'],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatStatut(item['statut']),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          item['count'].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersStatsCard({
    required String title,
    required List<Map<String, dynamic>> data,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (data.isEmpty)
              const Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: data.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item['color'],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatUserType(item['type']),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          item['count'].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      // Modifiez l'action "Valider un bien" dans _buildQuickActions():
      {
        'title': 'Valider un bien',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BiensGestionScreen(),
            ),
          );
        },
      },
      {
        'title': 'Traiter demande',
        'icon': Icons.task_alt,
        'color': Colors.blue,
        'onTap': () {
          setState(() {
            _selectedIndex = 1; // Naviguer vers Demandes
          });
        },
      },
      {
        'title': 'Gérer réclamation',
        'icon': Icons.support_agent,
        'color': Colors.orange,
        'onTap': () {
          setState(() {
            _selectedIndex = 2; // Naviguer vers Réclamations
          });
        },
      },
      {
        'title': 'Voir rapports',
        'icon': Icons.assessment,
        'color': Colors.purple,
        'onTap': () {
          setState(() {
            _selectedIndex = 4; // Naviguer vers Rapports
          });
        },
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: actions.map((action) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: action['onTap'] as void Function(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    action['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDemandeCard(Map<String, dynamic> demande) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Demande #${demande['id']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorForDemandeStatut(demande['statut'])
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatStatut(demande['statut']),
                    style: TextStyle(
                      color: _getColorForDemandeStatut(demande['statut']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (demande['bienReference'] != null)
              Text(
                'Bien: ${demande['bienReference']}',
                style: const TextStyle(color: Colors.grey),
              ),
            if (demande['message'] != null)
              Text(
                'Message: ${demande['message']}',
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            if (demande['statut'] == 'EN_ATTENTE')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _traiterDemande(demande['id'], 'accepter'),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accepter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _traiterDemande(demande['id'], 'refuser'),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Refuser'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
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

  Widget _buildReclamationCard(Map<String, dynamic> reclamation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Réclamation #${reclamation['id']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorForReclamationStatut(reclamation['statut'])
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatStatut(reclamation['statut']),
                    style: TextStyle(
                      color: _getColorForReclamationStatut(reclamation['statut']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (reclamation['titre'] != null)
              Text(
                reclamation['titre'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (reclamation['description'] != null)
              Text(
                reclamation['description'],
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            if (reclamation['statut'] == 'EN_ATTENTE')
              ElevatedButton.icon(
                onPressed: () => _prendreEnChargeReclamation(reclamation['id']),
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Prendre en charge'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemandeFilterChips() {
    final filters = ['Toutes', 'En attente', 'Acceptées', 'Refusées'];

    return Wrap(
      spacing: 8,
      children: filters.map((filter) {
        return FilterChip(
          label: Text(filter),
          selected: filter == 'Toutes',
          onSelected: (selected) {
            // TODO: Filtrer la liste
          },
        );
      }).toList(),
    );
  }

  Widget _buildReclamationFilterChips() {
    final filters = ['Toutes', 'En attente', 'En cours', 'Résolues', 'Fermées'];

    return Wrap(
      spacing: 8,
      children: filters.map((filter) {
        return FilterChip(
          label: Text(filter),
          selected: filter == 'Toutes',
          onSelected: (selected) {
            // TODO: Filtrer la liste
          },
        );
      }).toList(),
    );
  }

  String _formatStatut(String statut) {
    return statut
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatUserType(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN':
        return 'Administrateur';
      case 'PROPRIETAIRE':
        return 'Propriétaire';
      case 'LOCATAIRE':
        return 'Locataire';
      default:
        return type;
    }
  }

  int get _biensLouesCount {
    // Vous devrez ajuster cette logique selon vos données
    return _totalContrats; // Simplification
  }

  Future<void> _traiterDemande(int id, String action) async {
    try {
      final token = await _getToken();
      final endpoint = action == 'accepter'
          ? '/api/v1/demandes-location/$id/accepter'
          : '/api/v1/demandes-location/$id/refuser';

      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: action == 'refuser'
            ? jsonEncode({'motifRefus': 'Refusé par l\'administrateur'})
            : null,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande ${action == 'accepter' ? 'acceptée' : 'refusée'}'),
            backgroundColor: action == 'accepter' ? Colors.green : Colors.red,
          ),
        );
        await _loadDashboardData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _prendreEnChargeReclamation(int id) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/reclamations/$id/prendre-en-charge'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'commentaire': 'Pris en charge'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réclamation prise en charge'),
            backgroundColor: Colors.blue,
          ),
        );
        await _loadDashboardData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDashboardData,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Notifications
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Profil
            },
            tooltip: 'Profil',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardSection(),
          _buildDemandesSection(),
          _buildReclamationsSection(),
          _buildParametresSection(),
          _buildRapportsSection(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueGrey.shade800,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Demandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Réclamations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Rapports',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Administrateur'),
            accountEmail: const Text('admin@system.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Colors.blueGrey),
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade800,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Tableau de bord'),
            selected: _selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.apartment),
            title: const Text('Gestion des biens'),
            onTap: () {
              // TODO: Naviguer vers biens
            },
          ),
          ListTile(
            leading: const Icon(Icons.request_page),
            title: const Text('Demandes de location'),
            selected: _selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Contrats'),
            onTap: () {
              // TODO: Naviguer vers contrats
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Réclamations'),
            selected: _selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Paiements'),
            onTap: () {
              // TODO: Naviguer vers paiements
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Utilisateurs'),
            onTap: () {
              // TODO: Naviguer vers utilisateurs
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Rapports'),
            selected: _selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(4);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            selected: _selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Aide & Support'),
            onTap: () {
              // TODO: Aide
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  // Section paramètres (à compléter selon vos besoins)
  Widget _buildParametresSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres système',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuration générale',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingItem(
                    title: 'Notifications par email',
                    subtitle: 'Activer/désactiver les notifications',
                    icon: Icons.email,
                    value: true,
                  ),
                  _buildSettingItem(
                    title: 'Notifications push',
                    subtitle: 'Recevoir des notifications push',
                    icon: Icons.notifications,
                    value: true,
                  ),
                  _buildSettingItem(
                    title: 'Mode maintenance',
                    subtitle: 'Mettre le système en maintenance',
                    icon: Icons.engineering,
                    value: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sécurité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingItem(
                    title: 'Authentification à deux facteurs',
                    subtitle: 'Exiger 2FA pour les administrateurs',
                    icon: Icons.security,
                    value: true,
                  ),
                  _buildSettingItem(
                    title: 'Journalisation des activités',
                    subtitle: 'Conserver les logs système',
                    icon: Icons.history,
                    value: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon),
      value: value,
      onChanged: (newValue) {
        // TODO: Sauvegarder le paramètre
      },
    );
  }
}