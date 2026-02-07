// lib/screens/proprietaire/home_proprietaire_screen.dart - Version CORRIGÉE
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/bien.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_color.dart';
import 'admin_dashboard_screen.dart';

// ========== POINT D'ENTRÉE PROPRIETAIRE ==========
// ========== POINT D'ENTRÉE PROPRIETAIRE ==========
class HomeScreenProprietaire extends StatelessWidget {
  const HomeScreenProprietaire({super.key});

  @override
  Widget build(BuildContext context) {
    // AJOUTEZ CETTE VÉRIFICATION
    return FutureBuilder<User?>(
      future: AuthService().getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          final userType = user.type?.toString().toUpperCase().trim() ?? '';

          // SI C'EST UN ADMIN, REDIRIGEZ VERS L'ADMIN
          if (userType == 'ADMIN' || userType.contains('ADMIN')) {
            // Redirection immédiate
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
                ),
              );
            });

            // Écran temporaire pendant la redirection
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Redirection vers l\'espace admin...'),
                  ],
                ),
              ),
            );
          }
        }

        // Sinon, affichez le dashboard propriétaire normal
        return const ProprietaireDashboardScreen();
      },
    );
  }
}


// ========== APP DRAWER PROPRIETAIRE PROFESSIONNEL ==========
class AppDrawerProprietaire extends StatefulWidget {
  const AppDrawerProprietaire({super.key});

  @override
  State<AppDrawerProprietaire> createState() => _AppDrawerProprietaireState();
}

class _AppDrawerProprietaireState extends State<AppDrawerProprietaire> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getProfile();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement utilisateur: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'P';

    // Nettoyer les espaces multiples et split
    final parts = fullName.trim().split(' ').where((part) => part.isNotEmpty).toList();

    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts[0][0].toUpperCase();

    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
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

    final initials = _getInitials(_currentUser?.fullName);

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
          // Badge Propriétaire
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
            ),
            child: const Text(
              'PROPRIÉTAIRE',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
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
                      _currentUser?.fullName ?? 'Propriétaire',
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
          // Bouton déconnexion en haut (optionnel)
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout_outlined, size: 18),
            label: const Text('Déconnexion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _menuItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: Icon(item.icon, size: 22, color: AppColors.gray700),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray800,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.gray400),
                  onTap: () {
                    Navigator.pop(context);
                    if (item.route.isNotEmpty) {
                      Navigator.pushNamed(context, item.route);
                    }
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }

  final List<MenuItem> _menuItems = [
    MenuItem(title: 'Tableau de bord', icon: Icons.dashboard_outlined, route: ''),
    MenuItem(title: 'Mes Biens', icon: Icons.apartment_outlined, route: '/proprietaire/mes_locataires_screen.dart-biens-proprietaire'),
    MenuItem(title: 'Nouveau Bien', icon: Icons.add_home_outlined, route: '/proprietaire/nouveau-bien'),
    MenuItem(title: 'Mes Locataires', icon: Icons.people_outlined, route: '/proprietaire/locataires'),
    MenuItem(title: 'Contrats', icon: Icons.assignment_outlined, route: '/proprietaire/contrats'),
    MenuItem(title: 'Paiements', icon: Icons.payment_outlined, route: '/proprietaire/paiements'),
    MenuItem(title: 'Statistiques', icon: Icons.analytics_outlined, route: '/proprietaire/statistiques'),
    MenuItem(title: 'Mon Profil', icon: Icons.person_outline, route: '/proprietaire/profile'),
    MenuItem(title: 'Paramètres', icon: Icons.settings_outlined, route: '/proprietaire/settings'),
  ];
}
class MenuItem {
  final String title;
  final IconData icon;
  final String route;

  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

// ========== TABLEAU DE BORD PROPRIETAIRE PROFESSIONNEL ==========
class ProprietaireDashboardScreen extends StatefulWidget {
  const ProprietaireDashboardScreen({super.key});

  @override
  State<ProprietaireDashboardScreen> createState() => _ProprietaireDashboardScreenState();
}

class _ProprietaireDashboardScreenState extends State<ProprietaireDashboardScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _refreshing = false;
  User? _currentUser;

  // Données
  List<Bien> _biens = [];
  int _totalBiens = 0;
  int _biensLoues = 0;
  int _biensDisponibles = 0;
  int _revenuMensuel = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = await _authService.getProfile();

      setState(() {
        _currentUser = user;
      });

      await _loadBiensProprietaire();

      setState(() {
        _isLoading = false;
        _refreshing = false;
      });
    } catch (e) {
      print('❌ Erreur chargement dashboard: $e');
      setState(() {
        _isLoading = false;
        _refreshing = false;
      });
    }
  }

  Future<void> _loadBiensProprietaire() async {
    try {
      if (_currentUser == null) {
        print('❌ Utilisateur non chargé');
        return;
      }

      print('🔄 Chargement des biens du propriétaire ${_currentUser!.id}...');

      // CORRECTION ICI : Ajouter l'ID dans l'URL
      final response = await _apiService.get('/api/v1/biens/proprietaire/${_currentUser!.id}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _biens = data.map((json) => Bien.fromJson(json)).toList();
          _totalBiens = _biens.length;
          _biensLoues = _biens.where((b) => b.statut == 'LOUE').length;
          _biensDisponibles = _biens.where((b) => b.statut == 'DISPONIBLE').length;

          // Calcul du revenu mensuel estimé
          _revenuMensuel = _biens
              .where((b) => b.statut == 'LOUE')
              .fold(0, (sum, b) => sum + b.loyerMensuel.toInt());
        });

        print('✅ ${_biens.length} biens chargés');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur chargement biens: $e');
      // En cas d'erreur, essayer de charger les biens publics comme fallback
      await _loadBiensPublicsAsFallback();
    }
  }

  Future<void> _loadBiensPublicsAsFallback() async {
    try {
      print('🔄 Fallback: Chargement des biens publics...');
      final response = await _apiService.get('/api/v1/biens/publics');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _biens = data.map((json) => Bien.fromJson(json)).toList();
          _totalBiens = _biens.length;
          _biensLoues = _biens.where((b) => b.statut == 'LOUE').length;
          _biensDisponibles = _biens.where((b) => b.statut == 'DISPONIBLE').length;
          _revenuMensuel = _biens
              .where((b) => b.statut == 'LOUE')
              .fold(0, (sum, b) => sum + b.loyerMensuel.toInt());
        });

        print('✅ ${_biens.length} biens publics chargés (fallback)');
      }
    } catch (e) {
      print('❌ Erreur chargement fallback: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() => _refreshing = true);
    await _loadDashboardData();
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color, String? subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(icon, size: 20, color: color),
                  ),
                ),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBienCard(Bien bien) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/proprietaire/bien-details',
            arguments: bien,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.gray100,
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
                    Icons.apartment_outlined,
                    size: 28,
                    color: AppColors.gray400,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatType(bien.typeBien),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bien.ville,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bien.adresse,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${bien.loyerMensuel.toStringAsFixed(0)} DH',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              fontSize: 11,
                              color: _getStatusColor(bien.statut),
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildActionCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, size: 24, color: color),
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
              const SizedBox(height: 4),
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

  Widget _buildGuideItem(String text, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'APPARTEMENT': return 'Appartement';
      case 'MAISON': return 'Maison';
      case 'VILLA': return 'Villa';
      case 'STUDIO': return 'Studio';
      default: return type;
    }
  }

  String _formatStatus(String statut) {
    switch (statut) {
      case 'DISPONIBLE': return 'Disponible';
      case 'LOUE': return 'Loué';
      case 'EN_MAINTENANCE': return 'Maintenance';
      default: return statut;
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'DISPONIBLE': return Colors.green;
      case 'LOUE': return Colors.deepPurple;
      case 'EN_MAINTENANCE': return Colors.orange;
      default: return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        drawer: const AppDrawerProprietaire(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.deepPurple),
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

    return Scaffold(
      drawer: const AppDrawerProprietaire(),
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
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
                  // Top bar
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
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                        ),
                        child: const Text(
                          'PROPRIÉTAIRE',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
                  const SizedBox(height: 24),
                  // Titre
                  const Text(
                    'Tableau de bord',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bienvenue, ${_currentUser?.firstName ?? 'Propriétaire'}',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Statistiques

                ],
              ),
            ),
            // Contenu
        Padding(  // <-- CHANGEMENT ICI : Padding au lieu de Expanded
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                        // Mes biens récents
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mes biens récents',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                            ),
                            if (_biens.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/proprietaire/mes_locataires_screen.dart-biens');
                                },
                                child: const Text(
                                  'Voir tout',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_biens.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.apartment_outlined,
                                  size: 56,
                                  color: AppColors.gray300,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucun bien publié',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.gray600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Commencez par publier votre premier bien',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.gray500,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/proprietaire/nouveau-bien');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                  ),
                                  child: const Text('Publier un bien'),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: _biens
                                .take(3)
                                .map((bien) => Column(
                              children: [
                                _buildBienCard(bien),
                                const SizedBox(height: 12),
                              ],
                            ))
                                .toList(),
                          ),
                        const SizedBox(height: 32),
                        // Actions rapides
                        const Text(
                          'Actions rapides',
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
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                          children: [
                            _buildActionCard(
                              'Publier un bien',
                              'Ajoutez un nouveau bien à louer',
                              Icons.add_home_outlined,
                              Colors.deepPurple,
                                  () => Navigator.pushNamed(context, '/proprietaire/nouveau-bien'),
                            ),
                            _buildActionCard(
                              'Mes Locataires',
                              'Consultez vos locataires actuels',
                              Icons.people_outlined,
                              Colors.green,
                                  () => Navigator.pushNamed(context, '/proprietaire/locataires'),
                            ),
                            _buildActionCard(
                              'Gérer les biens',
                              'Modifiez vos biens existants',
                              Icons.edit_road_outlined,
                              Colors.orange,
                                  () => Navigator.pushNamed(context, '/proprietaire/mes_locataires_screen.dart-biens'),
                            ),
                            _buildActionCard(
                              'Paiements',
                              'Suivez vos paiements locatifs',
                              Icons.payment_outlined,
                              Colors.blue,
                                  () => Navigator.pushNamed(context, '/proprietaire/paiements'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Guide de démarrage
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: Colors.deepPurple,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Guide de démarrage',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ...[
                                'Publiez votre bien avec des photos de qualité',
                                'Évaluez les demandes des locataires',
                                'Acceptez les demandes et générez un contrat',
                                'Suivez les paiements et l\'état du bien',
                                'Gérez les réclamations et l\'entretien',
                              ].asMap().entries.map((entry) => _buildGuideItem(entry.value, entry.key)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
        ],
                ),
              ),
            ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/proprietaire/nouveau-bien'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ========== ÉCRAN "MES BIENS" PROFESSIONNEL ==========
class MesBiensScreen extends StatefulWidget {
  const MesBiensScreen({super.key});

  @override
  State<MesBiensScreen> createState() => _MesBiensScreenState();
}

class _MesBiensScreenState extends State<MesBiensScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Bien> _biens = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadBiens();
  }

  Future<void> _loadBiens() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Récupérer l'utilisateur pour avoir son ID
      final user = await _authService.getProfile();

      // Utiliser l'ID dans l'URL
      final response = await _apiService.get('/api/v1/biens/proprietaire/${user.id}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _biens = data.map((json) => Bien.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur chargement biens: $e');
      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger vos biens';
      });
    }
  }

  Widget _buildBienCard(Bien bien) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/proprietaire/bien-details',
            arguments: bien,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.gray100,
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
                    Icons.apartment_outlined,
                    size: 32,
                    color: AppColors.gray400,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatType(bien.typeBien),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bien.ville,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bien.loyerMensuel.toStringAsFixed(0)} DH',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.deepPurple,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              fontSize: 12,
                              color: _getStatusColor(bien.statut),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Biens'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadBiens,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gray100,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      )
          : _error.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 20),
            Text(
              _error,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBiens,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : _biens.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment_outlined,
              size: 72,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun bien publié',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Commencez par publier votre premier bien',
              style: TextStyle(
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/proprietaire/nouveau-bien');
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Publier un bien'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadBiens,
        color: Colors.deepPurple,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _biens.length,
          itemBuilder: (context, index) {
            return _buildBienCard(_biens[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/proprietaire/nouveau-bien');
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'APPARTEMENT': return 'Appartement';
      case 'MAISON': return 'Maison';
      default: return type;
    }
  }

  String _formatStatus(String statut) {
    switch (statut) {
      case 'DISPONIBLE': return 'Disponible';
      case 'LOUE': return 'Loué';
      case 'EN_MAINTENANCE': return 'Maintenance';
      default: return statut;
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'DISPONIBLE': return Colors.green;
      case 'LOUE': return Colors.deepPurple;
      case 'EN_MAINTENANCE': return Colors.orange;
      default: return AppColors.gray500;
    }
  }
}

// ========== ÉCRAN "MES LOCATAIRES" PROFESSIONNEL ==========
class MesLocatairesScreen extends StatefulWidget {
  const MesLocatairesScreen({super.key});

  @override
  State<MesLocatairesScreen> createState() => _MesLocatairesScreenState();
}

class _MesLocatairesScreenState extends State<MesLocatairesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _locataires = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadLocataires();
  }

  Future<void> _loadLocataires() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Note: Vous devez créer cet endpoint dans votre backend
      final response = await _apiService.get('/api/v1/proprietaire/locataires');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _locataires = data is List ? data : [];
          _isLoading = false;
        });
      } else {
        // Fallback: simuler des données pour le test
        await _loadLocatairesMock();
      }
    } catch (e) {
      print('❌ Erreur chargement locataires: $e');
      await _loadLocatairesMock();
    }
  }

  Future<void> _loadLocatairesMock() async {
    // Données mockées en attendant l'implémentation backend
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _locataires = [
        {
          'id': 1,
          'nom': 'Mohammed Ali',
          'email': 'mohammed@example.com',
          'telephone': '0612345678',
          'bien': 'Appartement - Casablanca',
          'contrat': 'Contrat #001',
          'dateDebut': '2024-01-01',
          'dateFin': '2024-12-31',
          'loyer': 3500.0,
          'statut': 'ACTIF',
        },
        {
          'id': 2,
          'nom': 'Fatima Zahra',
          'email': 'fatima@example.com',
          'telephone': '0623456789',
          'bien': 'Studio - Rabat',
          'contrat': 'Contrat #002',
          'dateDebut': '2024-02-01',
          'dateFin': '2025-01-31',
          'loyer': 2500.0,
          'statut': 'ACTIF',
        },
        {
          'id': 3,
          'nom': 'Hassan Karim',
          'email': 'hassan@example.com',
          'telephone': '0634567890',
          'bien': 'Maison - Marrakech',
          'contrat': 'Contrat #003',
          'dateDebut': '2023-11-01',
          'dateFin': '2024-10-31',
          'loyer': 5500.0,
          'statut': 'TERMINE',
        },
      ];
      _isLoading = false;
    });
  }

  Widget _buildLocataireCard(Map<String, dynamic> locataire) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          child: Text(
            locataire['nom'].toString().substring(0, 1),
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          locataire['nom'] ?? 'Locataire',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locataire['bien'] ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatutColor(locataire['statut']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getStatutColor(locataire['statut']).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  locataire['statut'] ?? 'INCONNU',
                  style: TextStyle(
                    fontSize: 11,
                    color: _getStatutColor(locataire['statut']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Email', locataire['email'] ?? ''),
                _buildInfoRow('Téléphone', locataire['telephone'] ?? ''),
                _buildInfoRow('Contrat', locataire['contrat'] ?? ''),
                _buildInfoRow('Loyer', '${locataire['loyer']?.toStringAsFixed(0) ?? '0'} DH/mois'),
                _buildInfoRow('Début', _formatDate(locataire['dateDebut'] ?? '')),
                _buildInfoRow('Fin', _formatDate(locataire['dateFin'] ?? '')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message_outlined, size: 18),
                        label: const Text('Contacter'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('Contrat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'ACTIF': return Colors.green;
      case 'TERMINE': return AppColors.gray500;
      case 'RESILIE': return Colors.red;
      default: return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Locataires'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadLocataires,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gray100,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      )
          : _locataires.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 72,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun locataire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vos locataires apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lorsque vous louez un bien',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadLocataires,
        color: Colors.deepPurple,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _locataires.length,
          itemBuilder: (context, index) {
            return _buildLocataireCard(_locataires[index]);
          },
        ),
      ),
    );
  }
}