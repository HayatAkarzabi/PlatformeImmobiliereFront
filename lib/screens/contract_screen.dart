// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:gestion_immobilier_front/screens/reclamations_contrat_screen.dart';
// import '../models/contrat.dart';
// import '../services/auth_service.dart';
// import '../services/api_service.dart';
// import '../theme/app_color.dart';
// import 'create_reclamation_screen.dart';
//
//
// class ContratsScreen extends StatefulWidget {
//   const ContratsScreen({super.key});
//
//   @override
//   State<ContratsScreen> createState() => _ContratsScreenState();
// }
//
// class _ContratsScreenState extends State<ContratsScreen> {
//   final AuthService _authService = AuthService();
//   final ApiService _apiService = ApiService();
//   List<Contrat> _contrats = [];
//   bool _isLoading = true;
//   String _error = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadContrats();
//   }
//
//   Future<void> _loadContrats() async {
//     try {
//       print('🔄 Chargement des contrats...');
//
//       // 1. Récupérer le profil utilisateur
//       final user = await _authService.getProfile();
//
//       // 2. Charger les contrats selon le type d'utilisateur
//       if (user.type == 'LOCATAIRE') {
//         // Utiliser le vrai endpoint pour mes_locataires_screen.dart contrats
//         final response = await _apiService.get('/api/v1/contrats/mes-contrats');
//
//         if (response.statusCode == 200) {
//           final List<dynamic> data = jsonDecode(response.body);
//           setState(() {
//             _contrats = data.map((json) => Contrat.fromJson(json)).toList();
//             _isLoading = false;
//             _error = '';
//           });
//           print('✅ ${_contrats.length} contrats chargés');
//         } else {
//           throw Exception('Erreur serveur: ${response.statusCode}');
//         }
//       } else {
//         throw Exception('Cette fonctionnalité est réservée aux locataires');
//       }
//     } catch (e) {
//       print('❌ Erreur: $e');
//       setState(() {
//         _isLoading = false;
//         _error = 'Impossible de charger les contrats';
//       });
//     }
//   }
//
//   Future<void> _downloadContratDocument(int contratId) async {
//     try {
//       final response = await _apiService.get('/api/v1/contrats/$contratId/document');
//
//       if (response.statusCode == 200) {
//         // TODO: Implémenter le téléchargement du PDF
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Document du contrat téléchargé'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         throw Exception('Document non disponible');
//       }
//     } catch (e) {
//       print('❌ Erreur téléchargement: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erreur lors du téléchargement'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// // AJOUTE CES 2 MÉTHODES APRÈS _downloadContratDocument :
//
// // 1. Pour créer une réclamation
//   void _creerReclamation(Contrat contrat) {
//     Navigator.pop(context); // Ferme le bottom sheet
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CreateReclamationScreen(contrat: contrat),
//       ),
//     );
//   }
//
// // 2. Pour voir les réclamations d'un contrat
//   void _voirReclamations(Contrat contrat) {
//     Navigator.pop(context); // Ferme le bottom sheet
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ReclamationsContratScreen(contratId: contrat.id),
//       ),
//     );
//   }
//   // AJOUTEZ CES 3 MÉTHODES APRÈS _voirReclamations (ligne ~120)
//
// // 3. Méthode pour effectuer un paiement
//   // DANS ContratsScreen, MODIFIEZ LA MÉTHODE _effectuerPaiement :
//
//   void _effectuerPaiement(Contrat contrat) async {
//     Navigator.pop(context); // Ferme le bottom sheet
//
//     try {
//       // Récupérer le token d'authentification réel
//       final authService = AuthService();
//       final token = await authService.getToken();
//
//       if (token == null || token.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Vous devez être connecté pour effectuer un paiement'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//
//       // Récupérer l'utilisateur
//       final user = await authService.getProfile();
//
//       // Calculer le montant total (loyer + charges)
//       final montantTotal = (contrat.loyerMensuel ?? 0.0) + (contrat.charges ?? 0.0);
//
//       // Naviguer vers l'écran de paiement
//       Navigator.pushNamed(
//         context,
//         '/payment/process',
//         arguments: {
//           'contratId': contrat.id,
//           'userId': user.id, // Utiliser l'ID réel de l'utilisateur
//           'authToken': token, // Utiliser le vrai token
//           'montant': montantTotal,
//           'periode': _getCurrentPeriod(),
//           'contratReference': contrat.reference,
//           'montantLoyer': contrat.loyerMensuel ?? 0.0,
//           'montantCharges': contrat.charges ?? 0.0,
//           'proprietaireNom': 'Propriétaire',
//           'bienAdresse': contrat.bienAdresse ?? 'Adresse non disponible',
//         },
//       );
//     } catch (e) {
//       print('❌ Erreur lors de la préparation du paiement: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erreur: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
// // 4. Méthode pour obtenir la période actuelle
//   String _getCurrentPeriod() {
//     final now = DateTime.now();
//     final mois = [
//       'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
//       'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
//     ];
//     return '${mois[now.month - 1]} ${now.year}';
//   }
//
// // 5. Méthode pour récupérer l'utilisateur
//   Future<void> _loadUserAndNavigate(Contrat contrat) async {
//     try {
//       final user = await _authService.getProfile();
//       final montantTotal = (contrat.loyerMensuel ?? 0.0) + (contrat.charges ?? 0.0);
//
//       Navigator.pushNamed(
//         context,
//         '/payment/process',
//         arguments: {
//           'contratId': contrat.id,
//           'userId': user.id,
//           'authToken': user.token ?? '',
//           'montant': montantTotal,
//           'periode': _getCurrentPeriod(),
//           'contratReference': contrat.reference,
//           'montantLoyer': contrat.loyerMensuel ?? 0.0,
//           'montantCharges': contrat.charges ?? 0.0,
//           'proprietaireNom': 'Propriétaire',
//           'bienAdresse': contrat.bienAdresse ?? 'Adresse non disponible',
//         },
//       );
//     } catch (e) {
//       print('❌ Erreur chargement utilisateur: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erreur: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   // Fonction pour formater la date
//   String _formatDate(String dateStr) {
//     try {
//       final parts = dateStr.split('T')[0].split('-');
//       if (parts.length >= 3) {
//         return '${parts[2]}/${parts[1]}/${parts[0]}';
//       }
//       return dateStr;
//     } catch (e) {
//       return dateStr;
//     }
//   }
//
//   Color _getStatusColor(String statut) {
//     switch (statut) {
//       case 'ACTIF':
//         return AppColors.green600;
//       case 'EXPIRE':
//         return AppColors.orange600;
//       case 'RESILIE':
//         return AppColors.red600;
//       default:
//         return AppColors.gray500;
//     }
//   }
//
//   Widget _buildContratCard(Contrat contrat) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             contentPadding: const EdgeInsets.all(16),
//             leading: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: _getStatusColor(contrat.statut).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 contrat.statut == 'ACTIF'
//                     ? Icons.contrast_rounded
//                     : Icons.archive_rounded,
//                 color: _getStatusColor(contrat.statut),
//               ),
//             ),
//             title: Text(
//               'Contrat ${contrat.reference}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 4),
//                 Text(
//                   'Du ${_formatDate(contrat.dateDebut)} au ${_formatDate(contrat.dateFin)}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: AppColors.gray600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(contrat.statut).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     contrat.statut,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: _getStatusColor(contrat.statut),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             trailing: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '${contrat.loyerMensuel?.toStringAsFixed(2) ?? '0'} DH',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 if (contrat.charges != null && contrat.charges! > 0)
//                   Text(
//                     '+ ${contrat.charges!.toStringAsFixed(2)} DH charges',
//                     style: const TextStyle(
//                       fontSize: 10,
//                       color: AppColors.gray500,
//                     ),
//                   ),
//               ],
//             ),
//             onTap: () => _showContratDetails(contrat),
//           ),
//
//           // BOUTON "PAYER" SUR LA CARTE - AJOUTÉ
//           if (contrat.statut == 'ACTIF')
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 36,
//                 child: ElevatedButton.icon(
//                   onPressed: () => _effectuerPaiement(contrat),
//                   icon: const Icon(Icons.payment, size: 16),
//                   label: const Text('Payer ce mois'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//   void _showContratDetails(Contrat contrat) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: AppColors.gray300,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // BOUTON "PAYER MON LOYER" - AJOUTÉ
//               if (contrat.statut == 'ACTIF')
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => _effectuerPaiement(contrat),
//                     icon: const Icon(Icons.payment, size: 20),
//                     label: const Text(
//                       'PAYER MON LOYER',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//
//               if (contrat.statut == 'ACTIF') const SizedBox(height: 12),
//
//               // Bouton Télécharger PDF
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () => _downloadContratDocument(contrat.id),
//                   icon: const Icon(Icons.picture_as_pdf),
//                   label: const Text('Télécharger le contrat (PDF)'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red[700],
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               // Bouton Ajouter une réclamation (seulement si contrat ACTIF)
//               if (contrat.statut == 'ACTIF')
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => _creerReclamation(contrat),
//                     icon: const Icon(Icons.report_problem),
//                     label: const Text('Signaler un problème'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange[700],
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//
//               const SizedBox(height: 12),
//
//               // Bouton Voir les réclamations existantes
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () => _voirReclamations(contrat),
//                   icon: const Icon(Icons.list),
//                   label: const Text('Voir mes réclamations'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: AppColors.primary,
//                     side: BorderSide(color: AppColors.primary),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(
//                 color: AppColors.gray600,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 15,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Mes contrats'),
//         ),
//         body: const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     if (_error.isNotEmpty) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Mes contrats'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 size: 60,
//                 color: AppColors.gray400,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _error,
//                 style: const TextStyle(
//                   color: AppColors.gray600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _loadContrats,
//                 child: const Text('Réessayer'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mes contrats'),
//         actions: [
//           IconButton(
//             onPressed: _loadContrats,
//             icon: const Icon(Icons.refresh_rounded),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadContrats,
//         child: _contrats.isEmpty
//             ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.description_rounded,
//                 size: 60,
//                 color: AppColors.gray300,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Vous n\'avez aucun contrat',
//                 style: TextStyle(
//                   color: AppColors.gray600,
//                 ),
//               ),
//             ],
//           ),
//         )
//             : ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: _contrats.length,
//           itemBuilder: (context, index) {
//             return _buildContratCard(_contrats[index]);
//           },
//         ),
//       ),
//     );
//   }
// }
//
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:gestion_immobilier_front/screens/reclamations_contrat_screen.dart';
import '../models/contrat.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_color.dart';
import 'create_reclamation_screen.dart';
// IMPORTANT: Ajoutez cet import
import 'package:flutter/foundation.dart' show kIsWeb;

// Si vous êtes sur Web, ajoutez aussi :
import 'dart:html' as html;
// OU si vous avez des problèmes, utilisez cette approche alternative

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

  // Variables pour les quittances
  bool _loadingQuittances = false;
  List<dynamic> _quittances = [];

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
          const SnackBar(
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
        const SnackBar(
          content: Text('Erreur lors du téléchargement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

  // 3. Méthode pour effectuer un paiement
  void _effectuerPaiement(Contrat contrat) async {
    Navigator.pop(context); // Ferme le bottom sheet

    try {
      // Récupérer le token d'authentification réel
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour effectuer un paiement'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Récupérer l'utilisateur
      final user = await authService.getProfile();

      // Calculer le montant total (loyer + charges)
      final montantTotal = (contrat.loyerMensuel ?? 0.0) + (contrat.charges ?? 0.0);

      // Naviguer vers l'écran de paiement
      Navigator.pushNamed(
        context,
        '/payment/process',
        arguments: {
          'contratId': contrat.id,
          'userId': user.id,
          'authToken': token,
          'montant': montantTotal,
          'periode': _getCurrentPeriod(),
          'contratReference': contrat.reference,
          'montantLoyer': contrat.loyerMensuel ?? 0.0,
          'montantCharges': contrat.charges ?? 0.0,
          'proprietaireNom': 'Propriétaire',
          'bienAdresse': contrat.bienAdresse ?? 'Adresse non disponible',
        },
      );
    } catch (e) {
      print('❌ Erreur lors de la préparation du paiement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 4. Méthode pour obtenir la période actuelle
  String _getCurrentPeriod() {
    final now = DateTime.now();
    final mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${mois[now.month - 1]} ${now.year}';
  }

  // 5. Méthode pour récupérer l'utilisateur
  Future<void> _loadUserAndNavigate(Contrat contrat) async {
    try {
      final user = await _authService.getProfile();
      final montantTotal = (contrat.loyerMensuel ?? 0.0) + (contrat.charges ?? 0.0);

      Navigator.pushNamed(
        context,
        '/payment/process',
        arguments: {
          'contratId': contrat.id,
          'userId': user.id,
          'authToken': user.token ?? '',
          'montant': montantTotal,
          'periode': _getCurrentPeriod(),
          'contratReference': contrat.reference,
          'montantLoyer': contrat.loyerMensuel ?? 0.0,
          'montantCharges': contrat.charges ?? 0.0,
          'proprietaireNom': 'Propriétaire',
          'bienAdresse': contrat.bienAdresse ?? 'Adresse non disponible',
        },
      );
    } catch (e) {
      print('❌ Erreur chargement utilisateur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 6. Charger toutes les quittances (reçus de paiement)
  Future<void> _loadQuittances() async {
    try {
      setState(() {
        _loadingQuittances = true;
      });

      print('🔄 Chargement des quittances...');

      // 1. Récupérer le profil utilisateur
      final user = await _authService.getProfile();

      // 2. Charger les paiements payés
      final response = await _apiService.get('/payments/locataire/${user.id}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> paiementsList = [];

        // Adapter selon la structure de la réponse
        if (data is List) {
          paiementsList = data;
        } else if (data is Map && data.containsKey('content')) {
          paiementsList = data['content'] is List ? data['content'] : [];
        } else if (data is Map && data.containsKey('data')) {
          paiementsList = data['data'] is List ? data['data'] : [];
        }

        // Filtrer seulement les paiements payés
        final quittances = paiementsList.where((paiement) {
          final statut = paiement['statut']?.toString() ?? '';
          return statut == 'COMPLETED' ||
              statut == 'CAPTURED' ||
              statut == 'PAYE' ||
              paiement['capturedAt'] != null;
        }).toList();

        setState(() {
          _quittances = quittances;
          _loadingQuittances = false;
        });

        print('✅ ${_quittances.length} quittances trouvées');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur chargement quittances: $e');
      setState(() {
        _loadingQuittances = false;
        _quittances = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 7. Télécharger une quittance spécifique
  Future<void> _downloadQuittance(int paymentId) async {
    try {
      print('📥 Téléchargement quittance ID: $paymentId');

      final bytes = await _apiService.downloadReceipt(paymentId);

      // Sauvegarder et ouvrir le fichier
      await _saveAndOpenPdf(bytes, 'quittance_$paymentId');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quittance téléchargée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('❌ Erreur téléchargement quittance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléchargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 8. Sauvegarder et ouvrir le PDF
  // Version encore plus simple
  Future<void> _saveAndOpenPdf(Uint8List bytes, String fileName) async {
    try {
      if (kIsWeb) {
        // WEB: Téléchargement simple
        final base64 = base64Encode(bytes);
        final url = 'data:application/pdf;base64,$base64';
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.pdf')
          ..click();
      } else {
        // MOBILE: Sauvegarde + ouverture
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        // Essayer d'ouvrir
        await OpenFile.open(filePath);
      }

      // Message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF téléchargé avec succès'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('❌ Erreur sauvegarde PDF: $e');

      // Message d'erreur mais avec succès de téléchargement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF téléchargé, vérifiez vos téléchargements'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  // 9. Afficher le dialogue des quittances
  void _showQuittancesDialog() {
    // Charger les quittances avant d'afficher le dialogue
    _loadQuittances().then((_) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.receipt, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Mes quittances'),
                  ],
                ),
                content: Container(
                  constraints: const BoxConstraints(maxWidth: 500, minWidth: 300),
                  child: _loadingQuittances
                      ? const Center(child: CircularProgressIndicator())
                      : _quittances.isEmpty
                      ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune quittance disponible',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Vous n\'avez pas encore de paiements effectués',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  )
                      : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var quittance in _quittances)
                          _buildQuittanceCard(quittance),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                  if (_quittances.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        // Option: Télécharger toutes les quittances en ZIP
                        // _downloadAllQuittances();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité à venir'),
                          ),
                        );
                      },
                      child: const Text('Tout télécharger'),
                    ),
                ],
              );
            },
          );
        },
      );
    });
  }

  // 10. Construire une carte de quittance
  Widget _buildQuittanceCard(Map<String, dynamic> quittance) {
    final paymentId = quittance['id'];
    final montant = quittance['montantTotal'] ?? quittance['montant'] ?? 0;
    final periode = quittance['periode'] ?? quittance['moisConcerne'] ?? 'N/A';
    final datePaiement = quittance['capturedAt'] ?? quittance['datePaiement'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Quittance #${quittance['reference'] ?? paymentId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Payé',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Période: $periode',
              style: const TextStyle(fontSize: 14),
            ),

            Text(
              'Montant: ${(montant is num ? montant.toDouble() : 0.0).toStringAsFixed(2)} DH',
              style: const TextStyle(fontSize: 14),
            ),

            if (datePaiement != 'N/A')
              Text(
                'Payé le: ${_formatDate(datePaiement.toString())}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Fermer le dialogue
                  _downloadQuittance(paymentId);
                },
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Télécharger la quittance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 11. Afficher les quittances pour un contrat spécifique
  void _showQuittancesForContrat(int contratId) async {
    try {
      print('🔄 Chargement des quittances pour contrat: $contratId');

      // 1. Récupérer le profil utilisateur
      final user = await _authService.getProfile();

      // 2. Charger les paiements pour ce contrat
      final response = await _apiService.get('/payments/locataire/${user.id}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> paiementsList = [];

        if (data is List) {
          paiementsList = data;
        } else if (data is Map && data.containsKey('content')) {
          paiementsList = data['content'] is List ? data['content'] : [];
        } else if (data is Map && data.containsKey('data')) {
          paiementsList = data['data'] is List ? data['data'] : [];
        }

        // Filtrer par contrat et paiements payés
        final quittances = paiementsList.where((paiement) {
          final paiementContratId = paiement['contrat']?['id'] ?? paiement['contratId'];
          final statut = paiement['statut']?.toString() ?? '';
          return paiementContratId == contratId &&
              (statut == 'COMPLETED' || statut == 'CAPTURED' || statut == 'PAYE' || paiement['capturedAt'] != null);
        }).toList();

        if (quittances.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune quittance pour ce contrat'),
            ),
          );
          return;
        }

        // Afficher le dialogue
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Quittances - Contrat #$contratId'),
              content: Container(
                constraints: const BoxConstraints(maxWidth: 500, minWidth: 300),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var quittance in quittances)
                        _buildQuittanceCard(quittance),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      child: Column(
        children: [
          ListTile(
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

          // BOUTON "PAYER" SUR LA CARTE - AJOUTÉ
          if (contrat.statut == 'ACTIF')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () => _effectuerPaiement(contrat),
                  icon: const Icon(Icons.payment, size: 16),
                  label: const Text('Payer ce mois'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
        ],
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

              const SizedBox(height: 20),

              // BOUTON "PAYER MON LOYER" - AJOUTÉ
              if (contrat.statut == 'ACTIF')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _effectuerPaiement(contrat),
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text(
                      'PAYER MON LOYER',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

              if (contrat.statut == 'ACTIF') const SizedBox(height: 12),


              const SizedBox(height: 12),

              // NOUVEAU BOUTON : Voir les quittances de ce contrat
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Fermer le bottom sheet
                    _showQuittancesForContrat(contrat.id);
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Voir les quittances'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bouton Ajouter une réclamation (seulement si contrat ACTIF)
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

              // Bouton Voir les réclamations existantes
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
          // NOUVEAU BOUTON POUR VOIR LES QUITTANCES
          IconButton(
            onPressed: _showQuittancesDialog,
            icon: const Icon(Icons.receipt),
            tooltip: 'Voir mes quittances',
          ),
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

