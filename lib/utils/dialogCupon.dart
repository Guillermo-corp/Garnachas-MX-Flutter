import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/product_provider.dart';
import 'package:flutter_application_1/models/cart_service.dart';

Future<void> mostrarCuponesDialog(BuildContext context) async {
  final email = FirebaseAuth.instance.currentUser?.email;

  if (email == null) {
    showFailureSnackbar(context, 'Error', 'Debes iniciar sesión');
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: SpinKitSquareCircle(color: Color(0xFFFF7643), size: 60.0),
    ),
  );

  try {
    final res = await http.get(
      Uri.parse('https://garnachas-mx.vercel.app/api/cupones?email=$email'),
    );

    final data = jsonDecode(res.body);
    final cupones = data['cupones'];

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    
    if (cupones.isEmpty) {
      showWarningSnackbar(
        context,
        'Sin cupones',
        'No tienes cupones disponibles.',
      );
    } else {
      final cuponList = cupones.map<Widget>((cupon) {
        final rawDescuento = cupon['descuento'];
        final doubleDescuento = double.tryParse(rawDescuento.toString()) ?? 0.0;
        final descuento = (doubleDescuento * 100).toInt();
        return ListTile(
          leading: Icon(Icons.local_offer, color: Colors.green),
          title: Text("Cupón: ${cupon['codigo']}"),
          subtitle: Text("Descuento: $descuento%"),
          trailing: ElevatedButton(
            child: Text("Canjear"),
            onPressed: () async {
              final res = await http.patch(
                Uri.parse('https://garnachas-mx.vercel.app/api/cupones'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'email': email, 'codigo': cupon['codigo']}),
              );
              if (res.statusCode == 200) {
                final data = jsonDecode(res.body);
                final raw = data['descuento'];
                final doubleDescuento = double.tryParse(raw.toString()) ?? 0.0;

                if (context.mounted) {
                  Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).applyVoucher(doubleDescuento, codigo: cupon['codigo']);
                  applyDiscountToCartItems(doubleDescuento);
                  showSuccessSnackbar(
                    context,
                    'Cupón aplicado',
                    '¡Descuento activado!',
                  );
                  Navigator.pop(context);
                }
              } else {
                showFailureSnackbar(
                  context,
                  'Error',
                  'No se pudo canjear el cupón',
                );
              }
            },
          ),
        );
      }).toList();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Tus cupones'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(shrinkWrap: true, children: cuponList),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    print('Error al obtener cupones: $e');
    if (!context.mounted) return;
    showFailureSnackbar(context, 'Error', 'No se pudieron cargar los cupones');
  }
}
