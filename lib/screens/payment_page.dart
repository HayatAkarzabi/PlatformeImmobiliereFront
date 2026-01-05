import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InteractivePaymentPage extends StatefulWidget {
  final double montant;
  final String periode;
  final String marchand;
  final int contratId;
  final int userId;
  final String authToken;

  const InteractivePaymentPage({
    super.key,
    required this.montant,
    required this.contratId,
    required this.userId,
    required this.authToken,
    this.periode = 'Mois courant',
    this.marchand = 'Propriétaire',
  });

  @override
  State<InteractivePaymentPage> createState() => _InteractivePaymentPageState();
}

class _InteractivePaymentPageState extends State<InteractivePaymentPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _loading = false;
  String _selectedMethod = 'Carte bancaire';
  late AnimationController _successController;
  late Animation<double> _successAnimation;
  int? _paymentId;
  String? _paymentReference;
  String? _receiptUrl;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod('Carte bancaire', Icons.credit_card, Colors.blue),
    PaymentMethod('PayPal', Icons.paypal, Colors.lightBlue),
    PaymentMethod('Apple Pay', Icons.apple, Colors.black87),
    PaymentMethod('Google Pay', Icons.android, Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _successAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  // Méthode pour initialiser le paiement dans le backend
  Future<Map<String, dynamic>> _initPayment() async {
    const String baseUrl = 'http://192.168.1.100:8000'; // Remplacez par votre IP
    final url = Uri.parse('$baseUrl/payments/init');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.authToken}',
      },
      body: jsonEncode({
        'contratId': widget.contratId,
        'userId': widget.userId,
        'moisConcerne': _getCurrentMonthDate(),
        'paymentMethod': _mapPaymentMethod(_selectedMethod),
        'cardNumber': _selectedMethod == 'Carte bancaire'
            ? _cardNumberController.text.replaceAll(' ', '')
            : null,
        'cardExpiry': _selectedMethod == 'Carte bancaire'
            ? _expiryController.text
            : null,
        'cardCVV': _selectedMethod == 'Carte bancaire'
            ? _cvvController.text
            : null,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec de l\'initialisation: ${response.statusCode}');
    }
  }

  // Méthode pour capturer le paiement (marquer comme réussi)
  Future<Map<String, dynamic>> _capturePayment(int paymentId) async {
    const String baseUrl = 'http://192.168.1.100:8000';
    final url = Uri.parse('$baseUrl/payments/$paymentId/capture');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.authToken}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec de la capture: ${response.statusCode}');
    }
  }

  // Méthode pour annuler le paiement
  Future<Map<String, dynamic>> _cancelPayment(int paymentId) async {
    const String baseUrl = 'http://192.168.1.100:8000';
    final url = Uri.parse('$baseUrl/payments/$paymentId/cancel');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.authToken}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec de l\'annulation: ${response.statusCode}');
    }
  }

  // Télécharger la quittance
  Future<void> _downloadReceipt(int paymentId) async {
    const String baseUrl = 'http://192.168.1.100:8000';
    final url = Uri.parse('$baseUrl/payments/receipt/$paymentId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
        },
      );

      if (response.statusCode == 200) {
        // Ici vous pouvez sauvegarder le PDF ou l'afficher
        // Pour l'instant, on montre juste un snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Quittance téléchargée (${response.bodyBytes.length} bytes)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getCurrentMonthDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  }

  String _mapPaymentMethod(String uiMethod) {
    switch (uiMethod) {
      case 'Carte bancaire':
        return 'CREDIT_CARD';
      case 'PayPal':
        return 'PAYPAL';
      case 'Apple Pay':
        return 'APPLE_PAY';
      case 'Google Pay':
        return 'GOOGLE_PAY';
      default:
        return 'OTHER';
    }
  }

  void _processRealPayment() async {
    // Validation pour carte bancaire
    if (_selectedMethod == 'Carte bancaire' && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Initialiser le paiement dans la base de données
      final initResponse = await _initPayment();

      _paymentId = initResponse['id'];
      _paymentReference = initResponse['reference'];

      // Simulation d'un délai de traitement bancaire
      await Future.delayed(const Duration(seconds: 2));

      // Simulation aléatoire de succès/échec (80% de succès)
      final success = Random().nextDouble() > 0.2;

      if (success) {
        try {
          // 2. Capturer le paiement (marquer comme réussi)
          final captureResponse = await _capturePayment(_paymentId!);

          _receiptUrl = captureResponse['receiptUrlStr'];

          // Animation de succès
          _successController.forward();
          await Future.delayed(const Duration(milliseconds: 500));

          // Afficher le résultat
          _showPaymentResultDialog(
            success: true,
            paymentReference: _paymentReference,
            receiptUrl: _receiptUrl,
          );

        } catch (e) {
          // Échec de capture, annuler le paiement
          await _cancelPayment(_paymentId!);
          _showPaymentResultDialog(
              success: false,
              error: 'Erreur de capture: $e'
          );
        }
      } else {
        // Échec simulé, annuler le paiement
        await _cancelPayment(_paymentId!);
        _showPaymentResultDialog(
            success: false,
            error: 'Paiement refusé par la banque'
        );
      }

    } catch (e) {
      // Erreur d'initialisation
      _showPaymentResultDialog(
          success: false,
          error: 'Erreur: $e'
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showPaymentResultDialog({
    required bool success,
    String? paymentReference,
    String? receiptUrl,
    String? error,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AnimatedBuilder(
        animation: _successAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: success ? _successAnimation.value : 1.0,
            child: child,
          );
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: success
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green.shade100, Colors.green.shade50],
              )
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade100, Colors.red.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: success ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    success ? Icons.check : Icons.close,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  success ? '🎉 Paiement réussi !' : '❌ Échec du paiement',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  success
                      ? 'Votre paiement de ${widget.montant.toStringAsFixed(2)} DH a été traité avec succès.'
                      : 'Désolé, votre paiement n\'a pas pu être traité. Veuillez réessayer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),

                // Référence du paiement
                if (success && paymentReference != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Référence: $paymentReference',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                // Informations d'erreur
                if (!success && error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _paymentMethods
                              .firstWhere((m) => m.name == _selectedMethod)
                              .color
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _paymentMethods
                              .firstWhere((m) => m.name == _selectedMethod)
                              .icon,
                          color: _paymentMethods
                              .firstWhere((m) => m.name == _selectedMethod)
                              .color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.marchand,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.periode,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${widget.montant.toStringAsFixed(2)} DH',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bouton pour télécharger la quittance
                if (success && receiptUrl != null && receiptUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadReceipt(_paymentId!),
                        icon: const Icon(Icons.download),
                        label: const Text('Télécharger la quittance'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (success) Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: success ? Colors.green : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      success ? 'Fermer' : 'Réessayer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(PaymentMethod method) {
    final selected = _selectedMethod == method.name;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [method.color, method.color.withOpacity(0.8)],
          )
              : null,
          color: selected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? method.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: method.color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              method.icon,
              color: selected ? Colors.white : method.color,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              method.name,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Carte de crédit visuelle
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blueAccent, Colors.purpleAccent],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CREDIT CARD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    Icon(
                      Icons.wifi,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  _cardNumberController.text.isEmpty
                      ? '**** **** **** ****'
                      : _formatCardNumber(_cardNumberController.text),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CARD HOLDER',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        const Text(
                          'VOTRE NOM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          _expiryController.text.isEmpty
                              ? 'MM/AA'
                              : _expiryController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Champs de formulaire
          TextFormField(
            controller: _cardNumberController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Numéro de carte',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Numéro requis';
              final digits = v.replaceAll(' ', '');
              if (digits.length != 16) return 'Doit contenir 16 chiffres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'MM/AA',
                    hintText: '12/25',
                    prefixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'MM/AA requis';
                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
                      return 'Format: MM/AA';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'CVV requis';
                    if (v.length != 3) return 'Doit contenir 3 chiffres';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCardNumber(String input) {
    final digits = input.replaceAll(' ', '');
    if (digits.length > 16) return '**** **** **** ****';

    String formatted = '';
    for (int i = 0; i < min(digits.length, 16); i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += i < digits.length ? digits[i] : '*';
    }

    // Ajouter les * manquants
    while (formatted.replaceAll(' ', '').length < 16) {
      if (formatted.replaceAll(' ', '').length % 4 == 0 && formatted.isNotEmpty) {
        formatted += ' *';
      } else {
        formatted += '*';
      }
    }

    return formatted;
  }

  Widget _buildOtherMethodForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _paymentMethods
                .firstWhere((m) => m.name == _selectedMethod)
                .icon,
            size: 60,
            color: _paymentMethods
                .firstWhere((m) => m.name == _selectedMethod)
                .color,
          ),
          const SizedBox(height: 16),
          Text(
            'Vous serez redirigé vers ${_selectedMethod}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur "PAYER" pour continuer',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Paiement Sécurisé',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // En-tête avec montant
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.indigo],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.marchand,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${widget.montant.toStringAsFixed(2)} DH',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.periode,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Méthodes de paiement
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Méthode de paiement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _paymentMethods.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, index) =>
                      _buildPaymentMethodButton(_paymentMethods[index]),
                ),
              ),
              const SizedBox(height: 30),

              // Formulaire
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _selectedMethod == 'Carte bancaire'
                    ? _buildCardForm()
                    : _buildOtherMethodForm(),
              ),

              const SizedBox(height: 40),

              // Bouton de paiement
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _loading ? null : _processRealPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: Colors.green.withOpacity(0.4),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'PAYER ${widget.montant.toStringAsFixed(2)} DH',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Paiement 100% sécurisé - Données cryptées',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // Informations de débogage (à cacher en production)
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de test:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contrat ID: ${widget.contratId}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'User ID: ${widget.userId}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Mois: ${_getCurrentMonthDate()}',
                      style: const TextStyle(fontSize: 12),
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
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final Color color;

  PaymentMethod(this.name, this.icon, this.color);
}