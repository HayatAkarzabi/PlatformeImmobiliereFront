// // lib/screens/admin/reclamations_screen.dart
// import 'package:flutter/material.dart';
// import '../../models/reclamation-detail.dart';
// import '../../services/reclamation_service.dart';
//
// class ReclamationsScreen extends StatefulWidget {
//   const ReclamationsScreen({super.key});
//
//   @override
//   State<ReclamationsScreen> createState() => _ReclamationsScreenState();
// }
//
// class _ReclamationsScreenState extends State<ReclamationsScreen> {
//   final ReclamationService _service = ReclamationService();
//   List<ReclamationDetail> _reclamations = [];
//   bool _isLoading = true;
//   String _error = '';
//   bool _useTestData = false;
//   String _selectedFilter = 'Toutes';
//   String _searchQuery = '';
//
//   final List<String> _filters = [
//     'Toutes',
//     'EN_ATTENTE',
//     'EN_COURS',
//     'RESOLUE',
//     'FERMEE',
//     'URGENTE',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadReclamations();
//   }
//
//   Future<void> _loadReclamations() async {
//     setState(() {
//       _isLoading = true;
//       _error = '';
//     });
//
//     try {
//       List<ReclamationDetail> reclamations;
//
//       if (_useTestData) {
//         reclamations = await _service.getReclamationsTest();
//       } else {
//         reclamations = await _service.getReclamations();
//       }
//
//       // Filtrer les réclamations
//       if (_selectedFilter != 'Toutes') {
//         if (_selectedFilter == 'URGENTE') {
//           reclamations = reclamations.where((r) => r.priorite == 'URGENTE').toList();
//         } else {
//           reclamations = reclamations.where((r) => r.statut == _selectedFilter).toList();
//         }
//       }
//
//       // Recherche
//       if (_searchQuery.isNotEmpty) {
//         reclamations = reclamations.where((r) {
//           return r.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//               r.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//               r.locataireNom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//               r.bienAdresse.toLowerCase().contains(_searchQuery.toLowerCase());
//         }).toList();
//       }
//
//       setState(() {
//         _reclamations = reclamations;
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
//   Widget _buildReclamationCard(ReclamationDetail reclamation) {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // En-tête
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         reclamation.titre,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Réclamation #${reclamation.id}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     _buildStatusBadge(reclamation.statut),
//                     const SizedBox(width: 8),
//                     _buildPriorityBadge(reclamation.priorite),
//                   ],
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 12),
//
//             // Informations du locataire
//             _buildInfoRow(Icons.person, reclamation.locataireNom),
//             _buildInfoRow(Icons.email, reclamation.locataireEmail),
//             if (reclamation.locataireTelephone != 'Non disponible')
//               _buildInfoRow(Icons.phone, reclamation.locataireTelephone),
//
//             const Divider(height: 20),
//
//             // Informations du bien
//             _buildInfoRow(Icons.location_on, reclamation.bienAdresse),
//             _buildInfoRow(Icons.description, 'Contrat: ${reclamation.contratReference}'),
//             _buildInfoRow(Icons.category, 'Type: ${_formatType(reclamation.typeReclamation)}'),
//
//             const SizedBox(height: 12),
//
//             // Description
//             const Text(
//               'Description:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               reclamation.description,
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontSize: 13, color: Colors.grey),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Date et actions
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   reclamation.formattedDate,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _showDetails(reclamation),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                   ),
//                   child: const Text('Détails'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 16, color: Colors.grey),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(fontSize: 14),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusBadge(String status) {
//     Color color;
//     String text;
//
//     switch (status.toUpperCase()) {
//       case 'EN_ATTENTE':
//         color = Colors.orange;
//         text = 'En attente';
//         break;
//       case 'EN_COURS':
//         color = Colors.blue;
//         text = 'En cours';
//         break;
//       case 'RESOLUE':
//         color = Colors.green;
//         text = 'Résolue';
//         break;
//       case 'FERMEE':
//         color = Colors.grey;
//         text = 'Fermée';
//         break;
//       default:
//         color = Colors.grey;
//         text = status;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           color: color,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPriorityBadge(String priority) {
//     Color color;
//     String text;
//
//     switch (priority.toUpperCase()) {
//       case 'URGENTE':
//         color = Colors.red;
//         text = 'Urgent';
//         break;
//       case 'HAUTE':
//         color = Colors.orange;
//         text = 'Haute';
//         break;
//       case 'MOYENNE':
//         color = Colors.blue;
//         text = 'Moyenne';
//         break;
//       case 'BASSE':
//         color = Colors.green;
//         text = 'Basse';
//         break;
//       default:
//         color = Colors.grey;
//         text = priority;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           color: color,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   String _formatType(String type) {
//     switch (type.toUpperCase()) {
//       case 'PLOMBERIE': return 'Plomberie';
//       case 'CHAUFFAGE': return 'Chauffage';
//       case 'ELECTRICITE': return 'Électricité';
//       case 'ASCENSEUR': return 'Ascenseur';
//       default: return type;
//     }
//   }
//
//   void _showDetails(ReclamationDetail reclamation) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Réclamation #${reclamation.id}'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Titre
//               Text(
//                 reclamation.titre,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Locataire
//               const Text(
//                 'Informations du locataire:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text('• Nom: ${reclamation.locataireNom}'),
//               Text('• Email: ${reclamation.locataireEmail}'),
//               if (reclamation.locataireTelephone != 'Non disponible')
//                 Text('• Téléphone: ${reclamation.locataireTelephone}'),
//
//               const SizedBox(height: 16),
//
//               // Bien
//               const Text(
//                 'Informations du bien:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text('• Adresse: ${reclamation.bienAdresse}'),
//               Text('• Contrat: ${reclamation.contratReference}'),
//               Text('• Type: ${_formatType(reclamation.typeReclamation)}'),
//
//               const SizedBox(height: 16),
//
//               // Réclamation
//               const Text(
//                 'Détails de la réclamation:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text('• Priorité: ${reclamation.priorite}'),
//               Text('• Statut: ${_formatStatusText(reclamation.statut)}'),
//               Text('• Date: ${reclamation.formattedDate}'),
//
//               const SizedBox(height: 8),
//               const Text('Description:'),
//               Text(reclamation.description),
//
//               const SizedBox(height: 16),
//
//               // Solution si existe
//               if (reclamation.solution != null && reclamation.solution!.isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Solution apportée:',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(reclamation.solution!),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Fermer'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatStatusText(String status) {
//     switch (status) {
//       case 'EN_ATTENTE': return 'En attente';
//       case 'EN_COURS': return 'En cours';
//       case 'RESOLUE': return 'Résolue';
//       case 'FERMEE': return 'Fermée';
//       default: return status;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Gestion des réclamations'),
//         actions: [
//           IconButton(
//             icon: Icon(_useTestData ? Icons.cloud : Icons.memory),
//             onPressed: () {
//               setState(() {
//                 _useTestData = !_useTestData;
//               });
//               _loadReclamations();
//             },
//             tooltip: _useTestData ? 'Utiliser API' : 'Utiliser données test',
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadReclamations,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Recherche et filtres
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Barre de recherche
//                 TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Rechercher...',
//                     prefixIcon: const Icon(Icons.search),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onChanged: (value) {
//                     setState(() {
//                       _searchQuery = value;
//                     });
//                     _loadReclamations();
//                   },
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Filtres
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: _filters.map((filter) {
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: ChoiceChip(
//                           label: Text(_formatFilterText(filter)),
//                           selected: _selectedFilter == filter,
//                           onSelected: (selected) {
//                             setState(() {
//                               _selectedFilter = selected ? filter : 'Toutes';
//                             });
//                             _loadReclamations();
//                           },
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Compteur
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${_reclamations.length} réclamation(s)',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 if (_useTestData)
//                   const Chip(
//                     label: Text('Mode test'),
//                     backgroundColor: Colors.orange,
//                     labelStyle: TextStyle(color: Colors.white),
//                   ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           // Liste
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _error.isNotEmpty
//                 ? Center(child: Text(_error))
//                 : _reclamations.isEmpty
//                 ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
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
//                 : ListView.builder(
//               padding: const EdgeInsets.all(8),
//               itemCount: _reclamations.length,
//               itemBuilder: (context, index) {
//                 return _buildReclamationCard(_reclamations[index]);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatFilterText(String filter) {
//     switch (filter) {
//       case 'Toutes': return 'Toutes';
//       case 'EN_ATTENTE': return 'En attente';
//       case 'EN_COURS': return 'En cours';
//       case 'RESOLUE': return 'Résolues';
//       case 'FERMEE': return 'Fermées';
//       case 'URGENTE': return 'Urgentes';
//       default: return filter;
//     }
//   }
// }