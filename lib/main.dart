import 'package:flutter/material.dart';
import 'package:gestion_immobilier_front/screens/biens_screen.dart';
import 'package:gestion_immobilier_front/screens/contract_screen.dart';
import 'package:gestion_immobilier_front/screens/mes_demandes_screen.dart';
import 'package:gestion_immobilier_front/screens/notifications_screen.dart';
import 'package:gestion_immobilier_front/screens/demande_envoyer_screen.dart';
import 'package:gestion_immobilier_front/screens/payments_screen.dart';
import 'package:gestion_immobilier_front/screens/profile_screen.dart';
import 'package:gestion_immobilier_front/screens/recherche_screen.dart';
import 'package:gestion_immobilier_front/screens/reclamations_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_color.dart';

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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
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
      home: _isLoggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/contrats': (context) => const ContratsScreen(),
        '/reclamations': (context) => const ReclamationsScreen(),
        '/profil': (context) => const ProfilScreen(),
        '/biens': (context) => const BiensScreen(),
        '/home': (context) => const HomeScreen(),
        '/paiements': (context) => const PaiementsScreen(),
        '/recherche': (context) => const RechercheScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/register': (context) => const RegisterScreen(),
        '/demandes': (context) => const MesDemandesScreen(),


        // '/nouvelle_demande' est géré par onGenerateRoute ci-dessous
      },
      // AJOUTE CETTE PARTIE POUR GÉRER LES ROUTES AVEC PARAMÈTRES
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/nouvelle_demande':
          // Vérifier que des arguments ont été fournis
            if (settings.arguments == null) {
              // Retourner à l'écran précédent ou afficher une erreur
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(
                    child: Text('Erreur: Paramètres manquants'),
                  ),
                ),
              );
            }

          default:
          // Pour les routes non trouvées
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                  child: Text('Page non trouvée'),
                ),
              ),
            );
        }
      },
    );
  }
}