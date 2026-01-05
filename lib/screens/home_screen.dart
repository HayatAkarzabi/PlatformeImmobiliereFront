// lib/screens/home/home_screen.dart - Version ESTHÉTIQUE AMÉLIORÉE
import 'package:flutter/material.dart';
import 'package:gestion_immobilier_front/screens/home_proprietaire_screen.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/bien.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_color.dart';

// ========== APP DRAWER AMÉLIORÉ ==========
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String _userRole = 'LOCATAIRE';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('user_role') ?? 'LOCATAIRE';
      final user = await _authService.getProfile();

      setState(() {
        _currentUser = user;
        _userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement utilisateur: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getUserTypeText() {
    switch (_userRole) {
      case 'LOCATAIRE':
        return 'Locataire';
      case 'PROPRIETAIRE':
        return 'Propriétaire';
      case 'ADMIN':
        return 'Administrateur';
      default:
        return 'Utilisateur';
    }
  }

  Color _getUserColor() {
    switch (_userRole) {
      case 'LOCATAIRE':
        return AppColors.primary;
      case 'PROPRIETAIRE':
        return Colors.deepPurple;
      case 'ADMIN':
        return Colors.redAccent;
      default:
        return AppColors.gray600;
    }
  }

  Widget _buildDrawerHeader() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.gray200),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final initials = _currentUser?.fullName.isNotEmpty == true
        ? _currentUser!.fullName.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getUserColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getUserColor().withOpacity(0.3)),
            ),
            child: Text(
              _getUserTypeText(),
              style: TextStyle(
                color: _getUserColor(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getUserColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _getUserColor().withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getUserColor(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.fullName ?? 'Utilisateur',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDrawerItems() {
    final items = <Map<String, dynamic>>[];

    items.addAll([
      {'title': 'Accueil', 'icon': Icons.home_outlined, 'route': '/'},
      {'title': 'Rechercher', 'icon': Icons.search_outlined, 'route': '/search'},
    ]);

    if (_userRole == 'LOCATAIRE') {
      items.addAll([
        {'title': 'Mes Demandes', 'icon': Icons.description_outlined, 'route': '/demandes'},
        {'title': 'Mes Contrats', 'icon': Icons.assignment_outlined, 'route': '/contrats'},
        {'title': 'Mes Paiements', 'icon': Icons.payment_outlined, 'route': '/paiements'},
        {'title': 'Mes Réclamations', 'icon': Icons.report_problem_outlined, 'route': '/reclamations'},
      ]);
    } else if (_userRole == 'PROPRIETAIRE') {
      items.addAll([
        {'title': 'Mes Biens', 'icon': Icons.apartment_outlined, 'route': '/biens'},
        {'title': 'Demandes reçues', 'icon': Icons.inbox_outlined, 'route': '/demandes-recues'},
        {'title': 'Contrats en cours', 'icon': Icons.assignment_outlined, 'route': '/contrats-proprietaire'},
        {'title': 'Paiements', 'icon': Icons.payment_outlined, 'route': '/paiements-proprietaire'},
      ]);
    }

    items.addAll([
      {'title': 'Notifications', 'icon': Icons.notifications_outlined, 'route': '/notifications'},
      {'title': 'Mon Profil', 'icon': Icons.person_outline, 'route': '/profile'},
      {'title': 'Paramètres', 'icon': Icons.settings_outlined, 'route': '/settings'},
      {'title': 'Aide & Support', 'icon': Icons.help_outline, 'route': '/help'},
    ]);

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _getDrawerItems();

    return Drawer(
      width: 300,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: Icon(item['icon'], size: 22, color: AppColors.gray700),
                  title: Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray800,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.gray400),
                  onTap: () {
                    Navigator.pop(context);
                    if (item['route'] == '/') {
                      // Reste sur la page actuelle
                    } else {
                      Navigator.pushNamed(context, item['route']);
                    }
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.gray200),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: const Icon(Icons.logout_outlined, size: 22, color: Colors.red),
              title: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _authService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ========== HOME SCREEN AMÉLIORÉ ==========
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  // États
  bool _isLoading = true;
  bool _refreshing = false;
  int _selectedViewIndex = 0;

  // Données utilisateur
  User? _currentUser;
  Map<String, dynamic> _userStats = {
    'demandes': 0,
    'contrats': 0,
    'paiements': 0,
    'biens_loues': 0,
  };

  // Données biens (pour la recherche)
  List<Bien> _biens = [];
  List<Bien> _filteredBiens = [];
  String _error = '';

  // Contrôleurs pour les filtres
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // Filtres
  String? _selectedType;
  bool _showFilters = false;
  final Map<String, bool> _equipements = {
    'Meublé': false,
    'Balcon': false,
    'Parking': false,
    'Ascenseur': false,
  };

  // Types de biens
  final List<String> _typesBien = [
    'APPARTEMENT',
    'MAISON',
    'VILLA',
    'STUDIO',
    'TERRAIN',
    'LOCAL_COMMERCIAL',
    'BUREAU'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final user = await _authService.getProfile();

      setState(() {
        _currentUser = user;
        _isLoading = false;
        _refreshing = false;
      });

      // Si locataire, charger ses statistiques et biens
      if (user.type == 'LOCATAIRE') {
        await Future.wait([
          _loadUserStatistics(user.id, user.type),
          _loadBiens(),
        ]);
      } else {
        HomeScreenProprietaire();
      }

    } catch (e) {
      print('❌ Erreur chargement utilisateur: $e');
      setState(() {
        _isLoading = false;
        _refreshing = false;
      });
    }
  }

  Future<void> _loadUserStatistics(int userId, String userType) async {
    try {
      Map<String, dynamic> stats = {
        'demandes': 0,
        'contrats': 0,
        'paiements': 0,
        'biens_loues': 0,
      };

      // Demandes
      try {
        final response = await _apiService.get('/api/v1/demandes-location/mes_locataires_screen.dart-demandes');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          stats['demandes'] = data is List ? data.length : 0;
        }
      } catch (e) {
        print('⚠️ Erreur demandes: $e');
      }

      // Contrats
      try {
        final response = await _apiService.get('/api/v1/contrats/mes_locataires_screen.dart-contrats');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is List) {
            stats['contrats'] = data.length;
            stats['biens_loues'] = data.where((c) => c['statut'] == 'ACTIF').length;
          }
        }
      } catch (e) {
        print('⚠️ Erreur contrats: $e');
      }

      // Paiements
      try {
        final response = await _apiService.get('/payments/locataire/$userId');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('content')) {
            stats['paiements'] = data['content'] is List ? data['content'].length : 0;
          } else if (data is List) {
            stats['paiements'] = data.length;
          }
        }
      } catch (e) {
        print('⚠️ Erreur paiements: $e');
      }

      setState(() {
        _userStats = stats;
      });

    } catch (e) {
      print('⚠️ Erreur statistiques: $e');
    }
  }

  Future<void> _loadBiens() async {
    setState(() {
      _error = '';
    });

    try {
      print('🔄 Chargement des biens publics...');
      final response = await _apiService.get('/api/v1/biens/publics');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _biens = data.map((json) => Bien.fromJson(json)).toList();
          _filteredBiens = List.from(_biens);
        });

        print('✅ ${_biens.length} biens chargés');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      setState(() {
        _error = 'Impossible de charger les biens';
      });
    }
  }

  Future<void> _tryRechercheAvancee() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url = '/api/v1/biens/recherche/avancee-safe?';
      final params = <String, String>{};

      if (_villeController.text.isNotEmpty) {
        params['ville'] = _villeController.text;
      }

      if (_selectedType != null) {
        params['typeBien'] = _selectedType!;
      }

      if (_minPriceController.text.isNotEmpty) {
        final min = double.tryParse(_minPriceController.text);
        if (min != null) params['prixMin'] = min.toString();
      }

      if (_maxPriceController.text.isNotEmpty) {
        final max = double.tryParse(_maxPriceController.text);
        if (max != null) params['prixMax'] = max.toString();
      }

      url += params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');

      print('🔍 Recherche sécurisée: $url');

      final response = await _apiService.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _filteredBiens = data.map((json) => Bien.fromJson(json)).toList();
          _isLoading = false;
          _showFilters = false;
        });

        print('✅ ${_filteredBiens.length} biens trouvés');
      } else {
        print('⚠️ Erreur ${response.statusCode}, filtrage local');
        _applyLocalFilters();
      }
    } catch (e) {
      print('❌ Erreur, filtrage local: $e');
      _applyLocalFilters();
    }
  }

  void _applyLocalFilters() {
    List<Bien> filtered = List.from(_biens);

    if (_villeController.text.isNotEmpty) {
      final ville = _villeController.text.toLowerCase();
      filtered = filtered.where((bien) => bien.ville.toLowerCase().contains(ville)).toList();
    }

    if (_selectedType != null) {
      filtered = filtered.where((bien) => bien.typeBien == _selectedType).toList();
    }

    if (_minPriceController.text.isNotEmpty) {
      final minPrice = double.tryParse(_minPriceController.text);
      if (minPrice != null) {
        filtered = filtered.where((bien) => bien.loyerMensuel >= minPrice).toList();
      }
    }

    if (_maxPriceController.text.isNotEmpty) {
      final maxPrice = double.tryParse(_maxPriceController.text);
      if (maxPrice != null) {
        filtered = filtered.where((bien) => bien.loyerMensuel <= maxPrice).toList();
      }
    }

    final selectedEquipements = _equipements.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedEquipements.isNotEmpty) {
      filtered = filtered.where((bien) {
        return selectedEquipements.every((eq) {
          switch (eq) {
            case 'Meublé':
              return bien.meuble;
            case 'Balcon':
              return bien.balcon;
            case 'Parking':
              return bien.parking;
            case 'Ascenseur':
              return bien.ascenseur;
            default:
              return false;
          }
        });
      }).toList();
    }

    setState(() {
      _filteredBiens = filtered;
      _isLoading = false;
      _showFilters = false;
    });
  }

  void _rechercheSimple() {
    final searchText = _searchController.text.toLowerCase().trim();

    if (searchText.isEmpty) {
      setState(() {
        _filteredBiens = List.from(_biens);
      });
      return;
    }

    setState(() {
      _filteredBiens = _biens.where((bien) {
        return bien.typeBien.toLowerCase().contains(searchText) ||
            bien.ville.toLowerCase().contains(searchText) ||
            bien.adresse.toLowerCase().contains(searchText) ||
            bien.reference.toLowerCase().contains(searchText) ||
            (bien.description?.toLowerCase().contains(searchText) ?? false);
      }).toList();
    });
  }

  void _resetFilters() {
    _searchController.clear();
    _villeController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _selectedType = null;

    for (var key in _equipements.keys) {
      _equipements[key] = false;
    }

    setState(() {
      _filteredBiens = List.from(_biens);
      _showFilters = false;
    });
  }

  void _applyFilters() {
    if (_villeController.text.isNotEmpty ||
        _selectedType != null ||
        _minPriceController.text.isNotEmpty ||
        _maxPriceController.text.isNotEmpty) {
      _tryRechercheAvancee();
    } else {
      _rechercheSimple();
    }
  }

  Future<void> _openGoogleMaps(String address, String city) async {
    final fullAddress = '$address, $city';
    final encodedAddress = Uri.encodeComponent(fullAddress);
    final url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir Google Maps'),
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() => _refreshing = true);
    await _loadInitialData();
  }

  // ========== WIDGETS DASHBOARD AMÉLIORÉS ==========

  Widget _buildDashboardHeader() {
    final userType = _currentUser?.type ?? 'LOCATAIRE';
    final userTypeText = userType == 'LOCATAIRE' ? 'Locataire' :
    userType == 'PROPRIETAIRE' ? 'Propriétaire' : 'Admin';

    final initials = (_currentUser?.firstName?.isNotEmpty ?? false)
        ? _currentUser!.firstName![0].toUpperCase()
        : (_currentUser?.lastName?.isNotEmpty ?? false)
        ? _currentUser!.lastName![0].toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.gray100,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Text(
                  userTypeText,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                onPressed: _refreshData,
                icon: _refreshing
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(Icons.refresh_rounded, size: 24),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.gray100,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Informations utilisateur
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.fullName ?? 'Utilisateur',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Statistiques
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final stats = [
                {'value': _userStats['demandes']!, 'label': 'Demandes', 'icon': Icons.description_outlined},
                {'value': _userStats['contrats']!, 'label': 'Contrats', 'icon': Icons.assignment_outlined},
                {'value': _userStats['paiements']!, 'label': 'Paiements', 'icon': Icons.payment_outlined},
                {'value': _userStats['biens_loues']!, 'label': 'Biens', 'icon': Icons.apartment_outlined},
              ];
              final stat = stats[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(stat['icon'] as IconData, size: 20, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      stat['value'].toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.gray200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFeatures() {
    final userType = _currentUser?.type ?? 'LOCATAIRE';

    return [
      {
        'title': 'Mes Contrats',
        'description': 'Consultez vos contrats de location',
        'icon': Icons.assignment_outlined,
        'color': AppColors.primary,
        'route': '/contrats',
      },
      {
        'title': 'Mes Paiements',
        'description': 'Suivez vos paiements et quittances',
        'icon': Icons.payment_outlined,
        'color': Colors.green,
        'route': '/paiements',
      },
      {
        'title': 'Mes Demandes',
        'description': 'Consultez vos demandes de location',
        'icon': Icons.description_outlined,
        'color': Colors.orange,
        'route': '/demandes',
      },
      {
        'title': 'Mes Biens',
        'description': 'Consulter vos biens',
        'icon': Icons.apartment_outlined,
        'color': Colors.purple,
        'route': '/biens',
      },
      {
        'title': 'Réclamations',
        'description': 'Gérez vos réclamations',
        'icon': Icons.report_problem_outlined,
        'color': Colors.red,
        'route': '/reclamations',
      },
      {
        'title': 'Notifications',
        'description': 'Voir vos notifications',
        'icon': Icons.notifications_outlined,
        'color': Colors.blue,
        'route': '/notifications',
      },
    ];
  }

  void _navigateToFeature(String route) {
    Navigator.pushNamed(context, route);
  }

  // ========== WIDGETS RECHERCHE AMÉLIORÉS ==========

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et bouton menu
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.gray100,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Recherche de biens',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list_rounded,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: _showFilters ? AppColors.primary.withOpacity(0.1) : AppColors.gray100,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un bien, une ville...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _rechercheSimple();
                },
              )
                  : null,
              filled: true,
              fillColor: AppColors.gray50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              hintStyle: TextStyle(color: AppColors.gray500),
            ),
            onChanged: (value) => _rechercheSimple(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBadge() {
    if (_biens.isEmpty || _error.isNotEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_filteredBiens.length} résultat${_filteredBiens.length > 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const Spacer(),
          if (_filteredBiens.length != _biens.length)
            TextButton(
              onPressed: _resetFilters,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(
                'Effacer les filtres',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewTab(String title, int index) {
    final isSelected = _selectedViewIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedViewIndex = index;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.gray600,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBienCard(Bien bien) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: bien.photos.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(bien.photos.first),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: bien.photos.isEmpty
                    ? Center(
                  child: Icon(
                    Icons.home_outlined,
                    size: 48,
                    color: AppColors.gray400,
                  ),
                )
                    : null,
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(bien.statut).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatStatus(bien.statut),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et prix
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatType(bien.typeBien),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bien.ville,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${bien.loyerMensuel.toStringAsFixed(0)} DH',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '/ mois',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Adresse
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        bien.adresse,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Caractéristiques
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (bien.surface > 0)
                      _buildFeatureChip(
                        icon: Icons.square_foot_outlined,
                        label: '${bien.surface.toInt()} m²',
                      ),
                    if (bien.nombreChambres != null && bien.nombreChambres! > 0)
                      _buildFeatureChip(
                        icon: Icons.bed_outlined,
                        label: '${bien.nombreChambres} ch',
                      ),
                    if (bien.nombreSallesBain != null && bien.nombreSallesBain! > 0)
                      _buildFeatureChip(
                        icon: Icons.bathtub_outlined,
                        label: '${bien.nombreSallesBain} sdb',
                      ),
                    if (bien.meuble)
                      _buildFeatureChip(
                        icon: Icons.chair_outlined,
                        label: 'Meublé',
                      ),
                    if (bien.parking)
                      _buildFeatureChip(
                        icon: Icons.local_parking_outlined,
                        label: 'Parking',
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bouton Voir détails
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showBienDetails(bien),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: AppColors.primary),
                    ),
                    child: Text(
                      'Voir les détails',

                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,

                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gray600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }

  // ========== Panneau de filtres amélioré ==========
  Widget _buildFilterPanel() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Titre et bouton fermer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 24),
                onPressed: () => setState(() => _showFilters = false),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.gray100,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ville
                  const Text(
                    'Localisation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _villeController,
                    decoration: InputDecoration(
                      hintText: 'Saisir une ville',
                      filled: true,
                      fillColor: AppColors.gray50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Type de bien
                  const Text(
                    'Type de bien',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _typesBien.map((type) {
                      final isSelected = _selectedType == type;
                      return FilterChip(
                        label: Text(
                          _formatType(type),
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : AppColors.gray700,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                        backgroundColor: AppColors.gray100,
                        selectedColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Prix
                  const Text(
                    'Prix mensuel (DH)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Min',
                            filled: true,
                            fillColor: AppColors.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Max',
                            filled: true,
                            fillColor: AppColors.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Équipements
                  const Text(
                    'Équipements',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _equipements.keys.map((eq) {
                      return FilterChip(
                        label: Text(
                          eq,
                          style: TextStyle(
                            fontSize: 13,
                            color: _equipements[eq]! ? Colors.white : AppColors.gray700,
                          ),
                        ),
                        selected: _equipements[eq]!,
                        onSelected: (selected) {
                          setState(() {
                            _equipements[eq] = selected;
                          });
                        },
                        backgroundColor: AppColors.gray100,
                        selectedColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetFilters,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AppColors.gray300),
                          ),
                          child: const Text(
                            'Réinitialiser',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Appliquer',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== Détails du bien améliorés ==========
  void _showBienDetails(Bien bien) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Galerie d'images
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: bien.photos.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(bien.photos.first),
                            fit: BoxFit.cover,
                          )
                              : null,
                          color: AppColors.gray100,
                        ),
                        child: bien.photos.isEmpty
                            ? Center(
                          child: Icon(
                            Icons.home_outlined,
                            size: 64,
                            color: AppColors.gray400,
                          ),
                        )
                            : null,
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre et statut
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatType(bien.typeBien),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        bien.ville,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.gray900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(bien.statut).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _getStatusColor(bien.statut).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    _formatStatus(bien.statut),
                                    style: TextStyle(
                                      color: _getStatusColor(bien.statut),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Adresse
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: AppColors.gray500,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    bien.adresse,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Prix
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${bien.loyerMensuel.toStringAsFixed(0)} DH',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Loyer mensuel',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildPriceDetail(
                                        'Charges',
                                        bien.charges > 0 ? '${bien.charges.toStringAsFixed(0)} DH' : 'Incluses',
                                      ),
                                      _buildPriceDetail(
                                        'Caution',
                                        '${bien.caution.toStringAsFixed(0)} DH',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Description
                            if (bien.description != null && bien.description!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    bien.description!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.gray600,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),

                            // Caractéristiques
                            const Text(
                              'Caractéristiques',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                            ),
                            const SizedBox(height: 16),

                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                              children: [
                                _buildDetailCard('Surface', '${bien.surface.toInt()} m²', Icons.square_foot_outlined),
                                if (bien.nombreChambres != null)
                                  _buildDetailCard('Chambres', '${bien.nombreChambres}', Icons.bed_outlined),
                                if (bien.nombreSallesBain != null)
                                  _buildDetailCard('Salles de bain', '${bien.nombreSallesBain}', Icons.bathtub_outlined),
                                _buildDetailCard('Type', _formatType(bien.typeBien), Icons.category_outlined),
                                if (bien.meuble)
                                  _buildDetailCard('Meublé', 'Oui', Icons.chair_outlined),
                                if (bien.parking)
                                  _buildDetailCard('Parking', 'Oui', Icons.local_parking_outlined),
                                if (bien.balcon)
                                  _buildDetailCard('Balcon', 'Oui', Icons.balcony_outlined),
                                if (bien.ascenseur)
                                  _buildDetailCard('Ascenseur', 'Oui', Icons.elevator_outlined),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // Bouton de demande
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/demande-screen',
                                    arguments: bien,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Demander la location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'DISPONIBLE':
        return Colors.green;
      case 'LOUE':
        return AppColors.primary;
      case 'EN_MAINTENANCE':
        return Colors.orange;
      default:
        return AppColors.gray500;
    }
  }

  String _formatStatus(String statut) {
    switch (statut) {
      case 'DISPONIBLE':
        return 'Disponible';
      case 'LOUE':
        return 'Loué';
      case 'EN_MAINTENANCE':
        return 'Maintenance';
      default:
        return statut;
    }
  }

  String _formatType(String type) {
    switch (type) {
      case 'APPARTEMENT':
        return 'Appartement';
      case 'MAISON':
        return 'Maison';
      case 'VILLA':
        return 'Villa';
      case 'STUDIO':
        return 'Studio';
      case 'TERRAIN':
        return 'Terrain';
      case 'LOCAL_COMMERCIAL':
        return 'Local Commercial';
      case 'BUREAU':
        return 'Bureau';
      default:
        return type;
    }
  }

  // ========== BUILD PRINCIPAL AMÉLIORÉ ==========

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        drawer: const AppDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                'Chargement de votre espace...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentUser?.type != 'LOCATAIRE') {
      return const HomeScreenProprietaire();

    }

    final features = _getFeatures();

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Menu de sélection
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.gray200)),
              ),
              child: Row(
                children: [
                  _buildViewTab('Tableau de bord', 0),
                  _buildViewTab('Rechercher', 1),
                ],
              ),
            ),

            // Contenu selon la sélection
            Expanded(
              child: IndexedStack(
                index: _selectedViewIndex,
                children: [
                  // DASHBOARD
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildDashboardHeader(),

                          // Fonctionnalités
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Services',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Accédez à vos services en un clic',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.gray600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.2,
                                  ),
                                  itemCount: features.length,
                                  itemBuilder: (context, index) {
                                    final feature = features[index];
                                    return _buildFeatureCard(
                                      feature['title'],
                                      feature['description'],
                                      feature['icon'],
                                      feature['color'],
                                          () => _navigateToFeature(feature['route']),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // RECHERCHE
                  Column(
                    children: [
                      _buildSearchHeader(),
                      _buildResultsBadge(),
                      Expanded(
                        child: _biens.isEmpty && _error.isNotEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppColors.gray300,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _error,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.gray600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _loadBiens,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                            : _filteredBiens.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_outlined,
                                size: 64,
                                color: AppColors.gray300,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Aucun bien trouvé',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Modifiez vos critères de recherche',
                                style: TextStyle(
                                  color: AppColors.gray500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _resetFilters,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                child: const Text('Réinitialiser les filtres'),
                              ),
                            ],
                          ),
                        )
                            : RefreshIndicator(
                          onRefresh: _loadBiens,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: _filteredBiens.length,
                            itemBuilder: (context, index) {
                              return _buildBienCard(_filteredBiens[index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Panneau de filtres
      bottomSheet: _showFilters ? _buildFilterPanel() : null,
    );
  }
}