// main.dart - VERSION CORRIGÉE AVEC REDIRECTION ADMIN
import 'package:flutter/material.dart';
import 'package:gestion_immobilier_front/screens/bien_screen_proprietaire.dart';
import 'package:gestion_immobilier_front/screens/biens_screen.dart';
import 'package:gestion_immobilier_front/screens/create_reclamation_screen.dart';
import 'package:gestion_immobilier_front/screens/mes_locataires_screen.dart';
import 'package:gestion_immobilier_front/screens/nouveau_bien_screen.dart';
import 'package:gestion_immobilier_front/screens/payment_page.dart';
import 'package:gestion_immobilier_front/screens/contract_screen.dart';
import 'package:gestion_immobilier_front/screens/mes_demandes_screen.dart';
import 'package:gestion_immobilier_front/screens/notifications_screen.dart';
import 'package:gestion_immobilier_front/screens/demande_envoyer_screen.dart';
import 'package:gestion_immobilier_front/screens/payments_screen.dart';
import 'package:gestion_immobilier_front/screens/profile_screen.dart';
import 'package:gestion_immobilier_front/screens/recherche_screen.dart';
import 'package:gestion_immobilier_front/screens/reclamations_contrat_screen.dart';
import 'package:gestion_immobilier_front/screens/reclamations_list_screen.dart';
import 'package:gestion_immobilier_front/screens/payment_result_page.dart';
import 'package:gestion_immobilier_front/screens/home_proprietaire_screen.dart';
import 'package:gestion_immobilier_front/screens/admin_dashboard_screen.dart'; // IMPORT AJOUTÉ

import 'models/bien.dart';
import 'models/contrat.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_color.dart';
import 'models/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Récupérer le profil pour connaître le type d'utilisateur
        final user = await _authService.getProfile();

        // DEBUG: Afficher les infos de l'utilisateur
        print('🎯 UTILISATEUR CONNECTÉ:');
        print('   👤 Nom: ${user.fullName}');
        print('   📧 Email: ${user.email}');
        print('   🏷️ Type: ${user.type}');
        print('   🔍 Est admin: ${user.type == 'ADMIN'}');
        print('   🔍 Est propriétaire: ${user.type == 'PROPRIETAIRE'}');

        setState(() {
          _currentUser = user;
          _isLoggedIn = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification du login: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  // Fonction pour déterminer l'écran d'accueil selon le type d'utilisateur
  Widget _getHomeScreen() {
    if (!_isLoggedIn) {
      return const LoginScreen();
    }

    final userType = _currentUser?.type?.toUpperCase() ?? 'LOCATAIRE';
    print('🏠 Redirection selon type utilisateur: $userType');

    // VÉRIFICATION ADMIN EN PREMIER
    if (userType == 'ADMIN' || userType.contains('ADMIN')) {
      print('🚀 Redirection vers Admin Dashboard');
      return const AdminDashboardScreen(); // IMPORTANT: Ajoutez ceci
    }

    // Ensuite vérifier PROPRIETAIRE
    if (userType == 'PROPRIETAIRE' || userType.contains('PROPRIETAIRE')) {
      print('🏠 Redirection vers Dashboard Propriétaire');
      return HomeScreenProprietaire();
    }

    // Par défaut: LOCATAIRE
    print('👤 Redirection vers Dashboard Locataire');
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion Immobilière',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.dark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        fontFamily: 'Inter',
      ),
      // Utiliser la fonction qui détermine l'écran selon le type d'utilisateur
      home: _getHomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/contrats': (context) => const ContratsScreen(),

        // ROUTE ADMIN - AJOUTÉE
        '/admin/dashboard': (context) => const AdminDashboardScreen(),

        // ROUTES PROPRIÉTAIRE
        '/proprietaire/dashboard': (context) => HomeScreenProprietaire(),
        '/proprietaire/mes_locataires_screen.dart-biens': (context) => MesBiensScreen(),
        '/proprietaire/locataires': (context) => MesLocatairesScreen(),

        // ROUTES RÉCLAMATIONS (LOCATAIRE)
        '/reclamations': (context) {
          final contratId = ModalRoute.of(context)!.settings.arguments as int;
          return ReclamationsContratScreen(contratId: contratId);
        },
        '/create-reclamation': (context) {
          final contrat = ModalRoute.of(context)!.settings.arguments as Contrat;
          return CreateReclamationScreen(contrat: contrat);
        },
        '/profil': (context) => const ProfilScreen(),
        '/biens': (context) => const BiensScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/home': (context) => const HomeScreen(),
        '/paiements': (context) => const PaiementsScreen(),
        '/recherche': (context) => const RechercheScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/register': (context) => const RegisterScreen(),
        '/proprietaire/locataires': (context) => const MesLocatairesProprietaireScreen(),
        '/demandes': (context) => const MesDemandesScreen(),
        '/proprietaire/mes_locataires_screen.dart-biens-proprietaire': (context) => const MesBiensProprietaireScreen(),

        '/payment': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return InteractivePaymentPage(
            montant: (args['montant'] as num?)?.toDouble() ?? 0.0,
            periode: args['periode'] as String? ?? 'Mois courant',
            marchand: args['marchand'] as String? ?? 'Propriétaire',
            contratId: args['contratId'] as int? ?? 0,
            userId: args['userId'] as int? ?? 0,
            authToken: args['authToken'] as String? ?? '',
          );
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/demande-screen') {
          final bien = settings.arguments as Bien;
          return MaterialPageRoute(
            builder: (_) => DemandeLocationScreen(bien: bien),
          );
        }
        return null;
      },
    );
  }
}