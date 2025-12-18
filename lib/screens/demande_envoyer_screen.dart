// // lib/screens/demandes/mes_demandes_screen.dart
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../models/demande_location.dart';
// import '../../theme/app_color.dart';
//
// class MesDemandesScreen extends StatefulWidget {
//   const MesDemandesScreen({super.key});
//
//   @override
//   State<MesDemandesScreen> createState() => _MesDemandesScreenState();
// }
//
// class _MesDemandesScreenState extends State<MesDemandesScreen> {
//   late Future<List<DemandeLocationResponse>> _demandesFuture;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDemandes();
//   }
//
//   Future<List<DemandeLocationResponse>> _fetchDemandes() async {
//     try {
//       // 1. Récupérer le token
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');
//
//       print('🔑 Token récupéré: ${token != null ? "OUI (${token.length} chars)" : "NON"}');
//
//       if (token == null || token.isEmpty) {
//         throw Exception('❌ Non connecté. Connectez-vous d\'abord.');
//       }
//
//       // 2. Appeler l'API
//       // ⚠️ REMPLACE PAR TON URL RÉELLE ⚠️
//       const baseUrl = 'http://localhost:8000'; // ou 'https://ton-api.com'
//       const endpoint = '/api/v1/demandes-location/mes-demandes';
//       final url = '$baseUrl$endpoint';
//
//       print('🌐 Appel API: $url');
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 10));
//
//       print('📊 Statut: ${response.statusCode}');
//       print('📦 Réponse (100 premiers caractères): ${response.body.length > 0 ? response.body.substring(0, response.body.length < 100 ? response.body.length : 100) : "VIDE"}');
//
//       // 3. Traiter la réponse
//       if (response.statusCode == 200) {
//         if (response.body.isEmpty) {
//           return []; // Liste vide
//         }
//
//         final decoded = json.decode(response.body);
//
//         if (decoded is List) {
//           return decoded.map<DemandeLocationResponse>((item) {
//             return DemandeLocationResponse.fromJson(item);
//           }).toList();
//         } else {
//           throw Exception('⚠️ Format de réponse invalide. Attendu: List, Reçu: ${decoded.runtimeType}');
//         }
//       } else if (response.statusCode == 401) {
//         throw Exception('🔒 Session expirée. Reconnectez-vous.');
//       } else if (response.statusCode == 404) {
//         throw Exception('❌ Endpoint non trouvé. Vérifiez: $url');
//       } else if (response.statusCode == 500) {
//         throw Exception('⚡ Erreur serveur. Réessayez plus tard.');
//       } else {
//         throw Exception('💥 Erreur ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       print('💣 Erreur complète: $e');
//       rethrow;
//     }
//   }
//
//   void _loadDemandes() {
//     setState(() {
//       _demandesFuture = _fetchDemandes();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mes demandes de location'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _isLoading ? null : _loadDemandes,
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<DemandeLocationResponse>>(
//         future: _demandesFuture,
//         builder: (context, snapshot) {
//           // DEBUG
//           print('🔄 État FutureBuilder: ${snapshot.connectionState}');
//           print('❌ Erreur: ${snapshot.error}');
//           print('✅ Données: ${snapshot.data?.length ?? 0} items');
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return _buildLoadingState();
//           }
//
//           if (snapshot.hasError) {
//             return _buildErrorState(snapshot.error!);
//           }
//
//           final demandes = snapshot.data ?? [];
//
//           if (demandes.isEmpty) {
//             return _buildEmptyState();
//           }
//
//           return _buildDemandesList(demandes);
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.pushNamed(context, '/nouvelle-demande'),
//         icon: const Icon(Icons.add),
//         label: const Text('Nouvelle demande'),
//         backgroundColor: AppColors.primary,
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 20),
//           Text('Chargement en cours...'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorState(Object error) {
//     String errorTitle = 'Erreur';
//     String errorDetail = error.toString();
//
//     if (errorDetail.contains('Non connecté') || errorDetail.contains('Token')) {
//       errorTitle = 'Connexion requise';
//       errorDetail = 'Veuillez vous connecter pour accéder à vos demandes.';
//     } else if (errorDetail.contains('Session expirée') || errorDetail.contains('401')) {
//       errorTitle = 'Session expirée';
//       errorDetail = 'Votre session a expiré. Veuillez vous reconnecter.';
//     } else if (errorDetail.contains('404')) {
//       errorTitle = 'Service introuvable';
//       errorDetail = 'L\'adresse de l\'API est incorrecte ou le service est indisponible.';
//     } else if (errorDetail.contains('timeout')) {
//       errorTitle = 'Temps d\'attente dépassé';
//       errorDetail = 'Le serveur met trop de temps à répondre. Vérifiez votre connexion.';
//     }
//
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 80,
//               color: Colors.red[400],
//             ),
//             const SizedBox(height: 24),
//             Text(
//               errorTitle,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red[400],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 errorDetail,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                   height: 1.5,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton.icon(
//               onPressed: _loadDemandes,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Réessayer'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextButton(
//               onPressed: () {
//                 // Rediriger vers la connexion
//                 Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     '/login',
//                         (route) => false
//                 );
//               },
//               child: const Text('Se connecter'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.inbox_outlined,
//               size: 100,
//               color: Colors.blueGrey[200],
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Aucune demande',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w300,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 'Vous n\'avez pas encore créé de demande de location.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                   height: 1.6,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton.icon(
//               onPressed: () => Navigator.pushNamed(context, '/nouvelle-demande'),
//               icon: const Icon(Icons.add_circle_outline),
//               label: const Text('Créer ma première demande'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDemandesList(List<DemandeLocationResponse> demandes) {
//     return RefreshIndicator(
//       onRefresh: () async {
//         _loadDemandes();
//         await _demandesFuture;
//       },
//       child: ListView.builder(
//         padding: const EdgeInsets.only(top: 16, bottom: 100),
//         itemCount: demandes.length,
//         itemBuilder: (context, index) {
//           final demande = demandes[index];
//           return _buildDemandeCard(demande);
//         },
//       ),
//     );
//   }
//
//   Widget _buildDemandeCard(DemandeLocationResponse demande) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     demande.bienReference,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 Chip(
//                   label: Text(
//                     demande.statut.displayName,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                   backgroundColor: demande.statut.color,
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 const Icon(Icons.location_on, size: 16, color: Colors.grey),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     '${demande.bienAdresse}, ${demande.bienVille}',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Début: ${demande.formattedDateDebut}',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const Spacer(),
//                 Text(
//                   'Durée: ${demande.dureeContrat} mois',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screens/demandes/mes_demandes_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/demande_location_response.dart';
import '../../services/api_service.dart';
import '../../theme/app_color.dart';
import '../models/demande_location.dart' hide DemandeLocationResponse;

class MesDemandesScreen extends StatefulWidget {
  const MesDemandesScreen({super.key});

  @override
  State<MesDemandesScreen> createState() => _MesDemandesScreenState();
}

class _MesDemandesScreenState extends State<MesDemandesScreen> {
  List<DemandeLocationResponse> _demandes = [];
  bool _isLoading = true;
  String _error = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  Future<void> _loadDemandes() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      print('🔄 Chargement des demandes...');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Veuillez vous connecter pour voir vos demandes';
          _isLoading = false;
        });
        return;
      }

      final response = await _apiService.get('/api/v1/demandes-location/mes-demandes');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _demandes = data.map((json) => DemandeLocationResponse.fromJson(json)).toList();
          _isLoading = false;
        });

        print('✅ ${_demandes.length} demandes chargées');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      setState(() {
        _error = 'Impossible de charger les demandes';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes demandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDemandes,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
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
              onPressed: _loadDemandes,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_demandes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune demande',
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous n\'avez pas encore fait de demande de location',
              style: TextStyle(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDemandes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _demandes.length,
        itemBuilder: (context, index) {
          return _buildDemandeCard(_demandes[index]);
        },
      ),
    );
  }

  Widget _buildDemandeCard(DemandeLocationResponse demande) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    demande.bienReference,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: demande.statutColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    demande.statutLabel,
                    style: TextStyle(
                      color: demande.statutColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
                    '${demande.bienAdresse}, ${demande.bienVille}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                    maxLines: 2,
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
                      'Début: ${demande.formattedDateDebut}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${demande.dureeContrat} mois',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (demande.dateTraitement != null)
                  Text(
                    'Traité le: ${demande.dateTraitement!.day}/${demande.dateTraitement!.month}/${demande.dateTraitement!.year}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.gray500,
                    ),
                  ),
              ],
            ),
            if (demande.motifRefus != null && demande.motifRefus!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: Colors.red,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Motif de refus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      demande.motifRefus!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (demande.message != null && demande.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Votre message: ${demande.message}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray600,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}