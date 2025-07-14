import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> crearClienteEnSalesforce({
  required String accessToken,
  required String instanceUrl,
  required String nombre,
  required String direccion,
  String? notas,
}) async {
  final url = Uri.parse('$instanceUrl/services/data/v59.0/sobjects/Cliente__c');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'Nombre__c': nombre,
      'Direccion__c': direccion,
      if (notas != null && notas.isNotEmpty) 'Notas__c': notas,
    }),
  );

  if (response.statusCode == 201) {
    final data = json.decode(response.body);
    print('Cliente creado en Salesforce con ID: ${data['id']}');
  } else {
    print('Error al crear cliente: ${response.body}');
    throw Exception('Error al crear cliente');
  }
}
