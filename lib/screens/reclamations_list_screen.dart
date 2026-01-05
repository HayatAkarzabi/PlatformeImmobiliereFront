// // lib/screens/reclamations_contrat_screen.dart
// import 'package:flutter/material.dart';
// import '../services/reclamation_service.dart';
// import '../models/reclamation.dart';
//
// class ReclamationsContratScreen extends StatefulWidget {
//   final int contratId;
//
//   const ReclamationsContratScreen({
//     super.key,
//     required this.contratId,
//   });
//
//   @override
//   State<ReclamationsContratScreen> createState() => _ReclamationsContratScreenState();
// }
//
// class _ReclamationsContratScreenState extends State<ReclamationsContratScreen> {
//   final ReclamationService _service = ReclamationService();
//   List<Reclamation> _reclamations = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadReclamations();
//   }
//
//   Future<void> _loadReclamations() async {
//     try {
//       final reclamations = await _service.getReclamationsByContrat(widget.contratId);
//       setState(() {
//         _reclamations = reclamations;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('❌ Erreur: $e');
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Widget _buildReclamationCard(Reclamation reclamation) {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: reclamation.statutColor.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             reclamation.type == 'URGENT'
//                 ? Icons.warning
//                 : Icons.info,
//             color: reclamation.statutColor,
//           ),
//         ),
//         title: Text(reclamation.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(reclamation.description, maxLines: 2, overflow: TextOverflow.ellipsis),
//             const SizedBox(height: 4),
//             Chip(
//               label: Text(reclamation.statutText),
//               backgroundColor: reclamation.statutColor.withOpacity(0.1),
//               labelStyle: TextStyle(color: reclamation.statutColor),
//             ),
//           ],
//         ),
//         trailing: Text(
//           reclamation.priorite == 'HAUTE' ? '🔥' :
//           reclamation.priorite == 'MOYENNE' ? '⚠️' : 'ℹ️',
//           style: const TextStyle(fontSize: 20),
//         ),
//         onTap: () {
//           // Pour aller aux détails
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Réclamations du contrat'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _reclamations.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
//             const SizedBox(height: 16),
//             const Text('Aucune réclamation'),
//             const SizedBox(height: 8),
//             const Text('Tout va bien pour ce contrat'),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Retour'),
//             ),
//           ],
//         ),
//       )
//           : RefreshIndicator(
//         onRefresh: _loadReclamations,
//         child: ListView.builder(
//           itemCount: _reclamations.length,
//           itemBuilder: (context, index) =>
//               _buildReclamationCard(_reclamations[index]),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Pour créer une nouvelle réclamation
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }