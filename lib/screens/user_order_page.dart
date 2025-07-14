import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final currentUser = FirebaseAuth.instance.currentUser;
final userEmail = currentUser?.email;

class MyOrdersPage extends StatelessWidget {
  final String userEmail;
  const MyOrdersPage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    Future<List<dynamic>> fetchUserOrders(String? email) async {
      if (email == null) return [];
      final response = await http.get(
        Uri.parse(
          'https://garnachas-mx.vercel.app/api/pedido-flutter?email=$email',
        ),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar los pedidos');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchUserOrders(userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitSquareCircle(color: Color(0xFFFF7643), size: 60.0),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los pedidos.'));
          }
          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return const Center(child: Text('Aún no has hecho ningún pedido.'));
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final productos = pedido['productos'] as List<dynamic>? ?? [];

              final rawDate = pedido['fecha'];
              String formattedDate = 'Sin fecha';

              if (rawDate != null && rawDate.toString().isNotEmpty) {
                final date = DateTime.tryParse(rawDate)?.toLocal();
                if (date != null) {
                  formattedDate = DateFormat(
                    "d 'de' MMMM 'de' yyyy 'a las' h:mm a",
                    'es_MX',
                  ).format(date);
                }
              }

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  title: Text(
                    "Pedido #${pedido['id'] ?? ''} - \$${pedido['total']} MXN",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  subtitle: Text("Fecha: $formattedDate"),
                  children: [
                    ListTile(
                      title: const Text("Nombre"),
                      subtitle: Text(pedido['nombre'] ?? ''),
                    ),
                    ListTile(
                      title: const Text("Dirección"),
                      subtitle: Text(
                        pedido['direccion'] is String
                            ? pedido['direccion']
                            : [
                                    pedido['direccion']?['calle'],
                                    pedido['direccion']?['cp'],
                                    pedido['direccion']?['colonia'],
                                    pedido['direccion']?['ciudad'],
                                  ]
                                  .where(
                                    (e) => e != null && e.toString().isNotEmpty,
                                  )
                                  .join(', '),
                      ),
                    ),
                    ListTile(
                      title: const Text("Email"),
                      subtitle: Text(pedido['email'] ?? ''),
                    ),
                    if (pedido['datos_adicionales'] != null &&
                        pedido['datos_adicionales'].toString().isNotEmpty)
                      ListTile(
                        title: const Text("Datos adicionales"),
                        subtitle: Text(pedido['datos_adicionales']),
                      ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Text(
                        "Productos:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...productos.map(
                      (prod) => ListTile(
                        title: Text(prod['nombre'] ?? ''),
                        subtitle: Text("Cantidad: ${prod['cantidad']}"),
                        trailing: Text("\$${prod['precio']}"),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
