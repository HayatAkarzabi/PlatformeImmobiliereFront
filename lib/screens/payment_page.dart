// import 'package:flutter/material.dart';
//
// import '../services/payement_service.dart';
//
// class PaymentProcessScreen extends StatefulWidget {
//   final int contratId;
//   final int userId;
//   final String authToken;
//   final double montant;
//   final String periode;
//
//   // Paramètres optionnels avec valeurs par défaut
//   final String contratReference;
//   final double montantLoyer;
//   final double montantCharges;
//   final String proprietaireNom;
//   final String bienAdresse;
//
//   const PaymentProcessScreen({
//     super.key,
//     required this.contratId,
//     required this.userId,
//     required this.authToken,
//     required this.montant,
//     required this.periode,
//     this.contratReference = '',
//     this.montantLoyer = 0.0,
//     this.montantCharges = 0.0,
//     this.proprietaireNom = 'Propriétaire',
//     this.bienAdresse = 'Adresse non disponible',
//   });
//
//   @override
//   State<PaymentProcessScreen> createState() => _PaymentProcessScreenState();
// }
//
// class _PaymentProcessScreenState extends State<PaymentProcessScreen> {
//   final _cardNumberController = TextEditingController();
//   final _expiryController = TextEditingController();
//   final _cvvController = TextEditingController();
//   bool _loading = false;
//
//   Future<void> _processPayment() async {
//     if (_cardNumberController.text.isEmpty ||
//         _expiryController.text.isEmpty ||
//         _cvvController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Veuillez remplir tous les champs')),
//       );
//       return;
//     }
//
//     setState(() => _loading = true);
//
//     try {
//       // 1. Initialiser le paiement
//       final initResult = await PaymentService.initPayment(
//         contratId: widget.contratId,
//         userId: widget.userId,
//         authToken: widget.authToken,
//         paymentMethod: 'CREDIT_CARD',
//         cardNumber: _cardNumberController.text,
//         cardExpiry: _expiryController.text,
//         cardCVV: _cvvController.text,
//       );
//
//       if (initResult['success'] != true) {
//         throw Exception(initResult['error']);
//       }
//
//       final paymentId = initResult['data']['id'];
//
//       // 2. Capturer le paiement (simuler un délai)
//       await Future.delayed(const Duration(seconds: 2));
//
//       final captureResult = await PaymentService.capturePayment(
//         paymentId: paymentId,
//         authToken: widget.authToken,
//       );
//
//       if (captureResult['success'] == true) {
//         // Succès
//         if (mounted) {
//           Navigator.pop(context, true);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Paiement effectué avec succès!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } else {
//         // Échec, annuler le paiement
//         await PaymentService.cancelPayment(
//           paymentId: paymentId,
//           authToken: widget.authToken,
//         );
//         throw Exception(captureResult['error'] ?? 'Paiement échoué');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Paiement sécurisé')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // RÉSUMÉ AMÉLIORÉ AVEC INFOS DU CONTRAT
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Détails du paiement',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     if (widget.contratReference.isNotEmpty)
//                       _buildDetailRow('Contrat:', widget.contratReference),
//
//                     if (widget.bienAdresse.isNotEmpty)
//                       _buildDetailRow('Adresse:', widget.bienAdresse),
//
//                     if (widget.proprietaireNom.isNotEmpty)
//                       _buildDetailRow('Propriétaire:', widget.proprietaireNom),
//
//                     _buildDetailRow('Période:', widget.periode),
//
//                     const Divider(height: 20),
//
//                     if (widget.montantLoyer > 0)
//                       _buildDetailRow('Loyer:', '${widget.montantLoyer.toStringAsFixed(2)} DH'),
//
//                     if (widget.montantCharges > 0)
//                       _buildDetailRow('Charges:', '${widget.montantCharges.toStringAsFixed(2)} DH'),
//
//                     const Divider(height: 20),
//
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'TOTAL À PAYER:',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           '${widget.montant.toStringAsFixed(2)} DH',
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             // Formulaire de carte
//             TextFormField(
//               controller: _cardNumberController,
//               decoration: const InputDecoration(
//                 labelText: 'Numéro de carte',
//                 prefixIcon: Icon(Icons.credit_card),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//
//             const SizedBox(height: 16),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: _expiryController,
//                     decoration: const InputDecoration(
//                       labelText: 'MM/AA',
//                       prefixIcon: Icon(Icons.calendar_today),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     controller: _cvvController,
//                     decoration: const InputDecoration(
//                       labelText: 'CVV',
//                       prefixIcon: Icon(Icons.lock),
//                     ),
//                     obscureText: true,
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//               ],
//             ),
//
//             const Spacer(),
//
//             // Bouton de paiement
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _processPayment,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: _loading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                   'PAYER MAINTENANT',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
// Widget _buildDetailRow(String label, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(color: Colors.grey),
//         ),
//         Text(
//           value,
//           style: const TextStyle(fontWeight: FontWeight.w500),
//         ),
//       ],
//     ),
//   );
// }

import 'package:flutter/material.dart';
import '../services/payement_service.dart';

class PaymentProcessScreen extends StatefulWidget {
  final int contratId;
  final int userId;
  final String authToken;
  final double montant;
  final String periode;

  // Paramètres optionnels
  final String contratReference;
  final double montantLoyer;
  final double montantCharges;
  final String proprietaireNom;
  final String bienAdresse;

  const PaymentProcessScreen({
    super.key,
    required this.contratId,
    required this.userId,
    required this.authToken,
    required this.montant,
    required this.periode,
    this.contratReference = '',
    this.montantLoyer = 0.0,
    this.montantCharges = 0.0,
    this.proprietaireNom = 'Propriétaire',
    this.bienAdresse = 'Adresse non disponible',
  });

  @override
  State<PaymentProcessScreen> createState() => _PaymentProcessScreenState();
}

class _PaymentProcessScreenState extends State<PaymentProcessScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _loading = false;

  Future<void> _processPayment() async {
    if (_cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Initialiser le paiement
      final initResult = await PaymentService.initPayment(
        contratId: widget.contratId,
        userId: widget.userId,
        authToken: widget.authToken,
        paymentMethod: 'CREDIT_CARD',
        cardNumber: _cardNumberController.text,
        cardExpiry: _expiryController.text,
        cardCVV: _cvvController.text,
      );

      if (initResult['success'] != true) {
        throw Exception(initResult['error']);
      }

      final paymentId = initResult['data']['id'];

      // 2. Capturer le paiement (simuler un délai)
      await Future.delayed(const Duration(seconds: 2));

      final captureResult = await PaymentService.capturePayment(
        paymentId: paymentId,
        authToken: widget.authToken,
      );

      if (captureResult['success'] == true) {
        // Succès
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paiement effectué avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Échec, annuler le paiement
        await PaymentService.cancelPayment(
          paymentId: paymentId,
          authToken: widget.authToken,
        );
        throw Exception(captureResult['error'] ?? 'Paiement échoué');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement sécurisé'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView( // CHANGEMENT IMPORTANT : Ajout de SingleChildScrollView
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Résumé du paiement
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résumé du paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (widget.contratReference.isNotEmpty)
                      _buildDetailRow('Contrat:', widget.contratReference),

                    if (widget.bienAdresse.isNotEmpty)
                      _buildDetailRow('Adresse:', widget.bienAdresse),

                    if (widget.proprietaireNom.isNotEmpty)
                      _buildDetailRow('Propriétaire:', widget.proprietaireNom),

                    _buildDetailRow('Période:', widget.periode),

                    const Divider(height: 20, thickness: 1),

                    if (widget.montantLoyer > 0)
                      _buildDetailRow('Loyer mensuel:', '${widget.montantLoyer.toStringAsFixed(2)} DH'),

                    if (widget.montantCharges > 0)
                      _buildDetailRow('Charges:', '${widget.montantCharges.toStringAsFixed(2)} DH'),

                    const Divider(height: 20, thickness: 1),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL À PAYER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            '${widget.montant.toStringAsFixed(2)} DH',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Section informations de paiement
            const Text(
              'Informations de paiement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Veuillez saisir les informations de votre carte bancaire',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Formulaire de carte
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Numéro de carte',
                hintText: '1234 5678 9012 3456',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: InputDecoration(
                      labelText: 'MM/AA',
                      hintText: '12/25',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Sécurité
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Paiement 100% sécurisé - Vos données sont cryptées',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Bouton de paiement
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'PAYER MAINTENANT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Message d'information
            const Center(
              child: Text(
                'Vous serez redirigé vers une page sécurisée',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 20), // Espace en bas pour éviter le débordement
          ],
        ),
      ),
    );
  }
}