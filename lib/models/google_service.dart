import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String apiKey;

  GeocodingService(this.apiKey);

  Future<Map<String, dynamic>?> getLatLngFromAddress(String address) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return {'lat': location['lat'], 'lng': location['lng']};
      }
    }

    return null;
  }

  Future<List<String>> getAddressSuggestions(String input) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apiKey&components=country:mx';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['predictions'] != null) {
        return List<String>.from(
          data['predictions'].map((p) => p['description']),
        );
      }
    }
    return [];
  }

  Future<Map<String, String>?> getAddressDetailsFromLatLng(
    double lat,
    double lng,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey&language=es';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final components = data['results'][0]['address_components'] as List;
        String calle = '';
        String numero = '';
        String cp = '';
        String localidad = '';
        String sublocalidad = '';

        for (var c in components) {
          final types = List<String>.from(c['types']);
          if (types.contains('route')) {
            calle = c['long_name'];
          }
          if (types.contains('street_number')) {
            numero = c['long_name'];
          }
          if (types.contains('postal_code')) {
            cp = c['long_name'];
          }
          if (types.contains('locality')) {
            localidad = c['long_name'];
          }
          if (types.contains('sublocality_level_1')) {
            sublocalidad = c['long_name'];
          }
        }

        String calleYNumero = numero.isNotEmpty ? '$calle $numero' : calle;
        String coloniaYLocalidad = '';
        if (sublocalidad.isNotEmpty && localidad.isNotEmpty) {
          coloniaYLocalidad = '$sublocalidad, $localidad';
        } else if (sublocalidad.isNotEmpty) {
          coloniaYLocalidad = sublocalidad;
        } else if (localidad.isNotEmpty) {
          coloniaYLocalidad = localidad;
        }

        return {'calle': calleYNumero, 'cp': cp, 'ciudad': coloniaYLocalidad};
      }
    }
    return null;
  }
}
