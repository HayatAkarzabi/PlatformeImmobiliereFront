// screens/recherche_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class RechercheScreen extends StatefulWidget {
  const RechercheScreen({super.key});

  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _results = [];

  final List<String> _allItems = [
    'Contrat Appartement T3',
    'Paiement Janvier 2024',
    'Paiement Février 2024',
    'Réclamation Chauffage',
    'Contrat Villa S+2',
    'Quittance Décembre 2023',
    'Réclamation Fuite cuisine',
    'Paiement Mars 2024',
    'Contrat Studio',
    'Réclamation Ascenseur',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _performSearch();
    });
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      _results = [];
      return;
    }

    _results = _allItems
        .where((item) =>
        item.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildSearchItem(String item, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          item,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.greyMedium),
        onTap: () {
          // TODO: Naviguer vers l'élément spécifique
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ouverture de: $item'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher contrats, paiements, réclamations...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.greyMedium),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.greyMedium),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          // Résultats ou suggestions
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildSuggestions()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggestions de recherche',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSuggestionChip('Contrats', Icons.contrast),
              _buildSuggestionChip('Paiements', Icons.payment),
              _buildSuggestionChip('Réclamations', Icons.report_problem),
              _buildSuggestionChip('Quittances', Icons.receipt),
              _buildSuggestionChip('Biens', Icons.home),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Recherches récentes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.history, color: AppColors.greyMedium),
                  title: const Text('Contrat Appartement'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {},
                  ),
                  onTap: () {
                    _searchController.text = 'Contrat Appartement';
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: AppColors.greyMedium),
                  title: const Text('Paiement Janvier'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {},
                  ),
                  onTap: () {
                    _searchController.text = 'Paiement Janvier';
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, IconData icon) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(
                color: AppColors.greyDark,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Essayez avec d\'autres mots-clés',
              style: TextStyle(
                color: AppColors.greyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Text(
          '${_results.length} résultat${_results.length > 1 ? 's' : ''} trouvé${_results.length > 1 ? 's' : ''}',
          style: TextStyle(
            color: AppColors.greyDark,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ..._results.map((item) {
          // Déterminer l'icône en fonction du type
          late IconData icon;
          late Color color;

          if (item.toLowerCase().contains('contrat')) {
            icon = Icons.contrast;
            color = AppColors.primary;
          } else if (item.toLowerCase().contains('paiement')) {
            icon = Icons.payment;
            color = Colors.green;
          } else if (item.toLowerCase().contains('réclamation')) {
            icon = Icons.report_problem;
            color = Colors.orange;
          } else if (item.toLowerCase().contains('quittance')) {
            icon = Icons.receipt;
            color = Colors.blue;
          } else {
            icon = Icons.description;
            color = AppColors.greyDark;
          }

          return _buildSearchItem(item, icon, color);
        }).toList(),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}