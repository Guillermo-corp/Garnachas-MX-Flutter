import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_application_1/models/cart_service.dart';
import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'address_autocomplete_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/product_provider.dart';

void showCashPaymentForm(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final streetController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final emailController = TextEditingController();
  const googleApiKey = 'AIzaSyB1L5IGTTnITI4Sos95IqBdgOPhNImHTYE';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 30,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "🧾 Pago en efectivo",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Por favor completa los siguientes datos para confirmar tu pedido.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 25),

                // Nombre
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: "Nombre completo",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    hintText: "Ej. usuario@correo.com",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 10),

                // Dirección con autocomplete
                AddressAutocompleteField(
                  controller: addressController,
                  apiKey: googleApiKey,
                  label: "Dirección de entrega",
                  onAddressSelected: (calle, cp, ciudad) {
                    streetController.text = calle;
                    postalCodeController.text = cp;
                    cityController.text = ciudad;
                    print("Dirección seleccionada: $calle, $cp, $ciudad");
                  },
                ),

                const SizedBox(height: 10),

                // Calle
                TextFormField(
                  controller: streetController,
                  decoration: InputDecoration(
                    labelText: "Calle y número",
                    hintText: "Ej. Av. Insurgentes 123",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),

                const SizedBox(height: 10),

                // Código Postal
                TextFormField(
                  controller: postalCodeController,
                  decoration: InputDecoration(
                    labelText: "Código Postal",
                    hintText: "Ej. 01234",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Campo requerido" : null,
                ),

                const SizedBox(height: 10),

                // Ciudad
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: "Localidad",
                    hintText: "Ej. Dos Ríos, Ciudad de México",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Campo requerido" : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.note),
                    labelText: "Datos adicionales",
                    hintText: "Ej. Nummero exterior, referencias",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 20),
                // Confirmar botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      "Confirmar pedido",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: SpinKitSquareCircle(
                              color: Color(0xFFFF7643),
                              size: 60.0,
                            ),
                          ),
                        );

                        final productos = cartItems
                            .map(
                              (item) => {
                                'nombre': item.title,
                                'cantidad': item.quantity,
                                'precio': item.price,
                              },
                            )
                            .toList();

                        final total = cartItems.fold<double>(
                          0,
                          (sum, item) => sum + (item.price * item.quantity),
                        );

                        final response = await http.post(
                          Uri.parse(
                            'https://garnachas-mx.vercel.app/api/pedido-flutter',
                          ),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'nombre': nameController.text,
                            'email': emailController.text,
                            'direccion': {
                              'calle': streetController.text,
                              'cp': postalCodeController.text,
                              'ciudad': cityController.text,
                            },

                            'productos': productos,
                            'total': total,
                          }),
                        );

                        await http.post(
                          Uri.parse(
                            'https://garnachas-mx.vercel.app/api/cupones',
                          ),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'email': FirebaseAuth.instance.currentUser!.email,
                          }),
                        );

                        Navigator.of(context, rootNavigator: true).pop();

                        Navigator.pop(context);
                        showSuccessSnackbar(
                          context,
                          'Gracias ${nameController.text}',
                          'Tu pedido en efectivo ha sido registrado.',
                        );
                        /* ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Gracias ${nameController.text}, tu pedido en efectivo ha sido registrado.",
                            ),
                          ),
                        ); */

                        final provider = Provider.of<ProductProvider>(
                          context,
                          listen: false,
                        );
                        if (provider.cuponCodigo != null) {
                          await http.put(
                            Uri.parse(
                              'https://garnachas-mx.vercel.app/api/cupones',
                            ),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'email': FirebaseAuth.instance.currentUser!.email,
                              'codigo': provider.cuponCodigo,
                            }),
                          );
                          provider.removeVoucher();
                        }

                        clearCart();
                        cartItemCount.value = 0;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
