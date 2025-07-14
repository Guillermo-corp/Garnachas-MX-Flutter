import 'package:http/http.dart' as http;
import '../constants.dart';

Future<String> loginSalesforce() async {
  final instanceUrl = baseUrl;
  final token = accessToken;

  final response = await http.get(
    Uri.parse('$instanceUrl/services/data/v59.0/sobjects/Account'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    print('✅ Acceso correcto a Account');
    print('Respuesta Account: ${response.body}');
    return 'Consulta exitosa';
  } else {
    print('❌ Error al consultar Account: ${response.statusCode}');
    print(response.body);
    return 'Error: ${response.body}';
  }
}
