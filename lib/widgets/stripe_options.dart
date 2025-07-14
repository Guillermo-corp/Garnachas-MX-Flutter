import 'dart:convert';
import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/models/cart_service.dart';
import 'package:flutter_application_1/widgets/cash_payment.dart';


class PaymentOptions {
  static Map<String, dynamic>? paymentIntent;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSuccess,
  }) async {
    print("🔔 PaymentOptions.show() ejecutado");
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text("Pagar en efectivo"),
                onTap: () {
                  Navigator.pop(context);
                  showCashPaymentForm(context);
                  /* ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pago en efectivo seleccionado")),
                  ); */
                },
              ),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text("Pagar con tarjeta"),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  // Esperar a que el bottomsheet se cierre
                  await Future.delayed(const Duration(milliseconds: 300));
                  await makePayment(context, onSuccess: onSuccess);
                  /* Navigator.pop(context);
                  await makePayment(context, onSuccess: onSuccess); */
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> makePayment(
    BuildContext context, {
    VoidCallback? onSuccess,
  }) async {
    try {
      print("Creando PaymentIntent...");
      /*     paymentIntent = await createPaymentIntent('1000', 'MXN');
 */
      final totalAmount = getCartTotalInCents().toString();
      paymentIntent = await createPaymentIntent(totalAmount, 'MXN');
      print("Intento creado: ${paymentIntent!['id']}");

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'Garnachas MX',
          style: ThemeMode.dark,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'MX',
            testEnv: true,
          ),
        ),
      );

      print("Mostrando PaymentSheet...");
      await Stripe.instance.presentPaymentSheet();
      print("Pago completado");

      if (!context.mounted) return; // chequea antes de usar

      /* // Guarda el ScaffoldMessenger antes de cualquier await
      final scaffoldMessenger = ScaffoldMessenger.of(context); */

      showSuccessSnackbar(
        context,
        '¡Pago exitoso!',
        'Gracias por tu compra en Garnachas MX.',
      );
      /* scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text("Pago exitoso ✅")),
    ); */
      clearCart();
      print(cartItems.length);
      onSuccess?.call();
    } catch (e) {
      print("Error durante el pago: $e");
      if (context.mounted) {
        showFailureSnackbar(context, 'Error', '$e');
      }
    }
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      final body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print('🔁 Respuesta completa de Stripe: ${response.body}');
      final decoded = jsonDecode(response.body);

      // Verifica si hubo error
      if (decoded['error'] != null) {
        print('❌ Error de Stripe: ${decoded['error']}');
        return {};
      }

      return decoded;
    } catch (err) {
      print('❌ Excepción en createPaymentIntent: $err');
      throw Exception('Fallo al crear el PaymentIntent: $err');
    }
  }

  /* static Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      final body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      return jsonDecode(response.body);
    } catch (err) {
      throw Exception('Fallo al crear el PaymentIntent: $err');
    }
  }
} */
}
