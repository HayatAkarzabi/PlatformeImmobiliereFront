// main.dart - VERSION CORRIGÉE AVEC REDIRECTION ADMIN
import 'package:flutter/material.dart';
import 'package:gestion_immobilier_front/screens/bien_gestion_screen.dart';
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

        // DEBUG DÉTAILLÉ
        print('🎯 ========== DEBUG CONNEXION ==========');
        print('   👤 Nom: ${user.fullName}');
        print('   📧 Email: ${user.email}');
        print('   🏷️ Type brut: "${user.type}"');
        print('   🏷️ Type formaté: "${user.type?.toString().toUpperCase().trim()}"');
        print('   📊 User complet: ${user.toJson()}');
        print('   🔍 Est admin: ${user.type?.toString().toUpperCase().contains("ADMIN")}');
        print('=======================================');

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

    final userType = _currentUser?.type?.toString().toUpperCase().trim() ?? 'LOCATAIRE';
    print('🏠 DEBUG Redirection - Type utilisateur: "$userType"');
    print('🏠 DEBUG Redirection - Type exact: ${_currentUser?.type}');
    print('🏠 DEBUG Redirection - User object: ${_currentUser?.toJson()}');

    // VÉRIFICATION ADMIN - AVEC PLUS DE FLEXIBILITÉ
    if (userType == 'ADMIN' ||
        userType.contains('ADMIN') ||
        userType == 'ROLE_ADMIN' ||
        userType == '["ADMIN"]' ||  // Cas où c'est un tableau JSON
        (userType.startsWith('[') && userType.contains('ADMIN'))) {
      print('🚀 ADMIN DÉTECTÉ - Redirection vers Admin Dashboard');
      return const AdminDashboardScreen();
    }

    // Vérification PROPRIETAIRE
    if (userType == 'PROPRIETAIRE' ||
        userType.contains('PROPRIETAIRE') ||
        userType == 'ROLE_PROPRIETAIRE' ||
        (userType.startsWith('[') && userType.contains('PROPRIETAIRE'))) {
      print('🏠 PROPRIETAIRE DÉTECTÉ - Redirection vers Dashboard Propriétaire');
      return HomeScreenProprietaire();
    }

    // Par défaut: LOCATAIRE
    print('👤 LOCATAIRE DÉTECTÉ - Redirection vers Dashboard Locataire');
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

        // // ROUTES PROPRIÉTAIRE
        // '/proprietaire/dashboard': (context) => HomeScreenProprietaire(),
        // '/proprietaire/mes_locataires_screen.dart-biens': (context) => MesBiensScreen(),
        // '/proprietaire/locataires': (context) => MesLocatairesScreen(),

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
        '/admin/biens': (context) => const BiensGestionScreen(),
        '/home': (context) => const HomeScreen(),
        '/recherche': (context) => const RechercheScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/register': (context) => const RegisterScreen(),
        '/proprietaire/locataires': (context) => const MesLocatairesProprietaireScreen(),
        '/demandes': (context) => const MesDemandesScreen(),
        '/proprietaire/nouveau-bien': (context) => const NouveauBienScreen(),
        '/paiements':(context)=>PaiementsScreen(),
        '/payment/process': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          if (args is Map<String, dynamic>) {
            return PaymentProcessScreen(
              contratId: args['contratId'] ?? 0,
              userId: args['userId'] ?? 0,
              authToken: args['authToken'] ?? '',
              montant: args['montant'] ?? 0.0,
              periode: args['periode'] ?? 'Mois courant',
              // Ces paramètres sont optionnels dans votre PaymentProcessScreen
              contratReference: args['contratReference'] ?? '',
              montantLoyer: args['montantLoyer'] ?? 0.0,
              montantCharges: args['montantCharges'] ?? 0.0,
              proprietaireNom: args['proprietaireNom'] ?? 'Propriétaire',
              bienAdresse: args['bienAdresse'] ?? 'Adresse non disponible',
            );
          }

          return const Scaffold(
            body: Center(child: Text('Paramètres manquants')),
          );
        },
      },

      // Gestion des routes dynamiques avec onGenerateRoute
      onGenerateRoute: (settings) {
        // Pour les routes dynamiques avec paramètres dans l'URL
        switch (settings.name) {
          case '/payment/history':
            final uri = Uri.parse(settings.name!);
            final contratId = int.tryParse(uri.queryParameters['contratId'] ?? '');

            return MaterialPageRoute(
               builder: (context) =>PaiementsScreen(),
            );

          case '/payment/details':
            final paymentId = settings.arguments as int? ?? 0;
            // Vous pouvez créer un écran PaymentDetailsScreen ici
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Détails du paiement')),
                body: Center(child: Text('Détails du paiement #$paymentId')),
              ),
            );
        }

      },


    );
  }
}
