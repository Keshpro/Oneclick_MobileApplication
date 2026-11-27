import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';

class RoadRoutingService {
  // OSRM-compatible base URL, e.g. https://your-server/route/v1/driving
  static const endpoint = String.fromEnvironment('DD_ROUTING_URL');
  Future<({double distanceKm, int durationMinutes})?> route(
    LocationModel a,
    LocationModel b,
  ) async {
    if (endpoint.isEmpty ||
        a.latitude == null ||
        a.longitude == null ||
        b.latitude == null ||
        b.longitude == null)
      return null;
    try {
      final base = Uri.parse(endpoint);
      if (base.scheme != 'https' || base.host.isEmpty) return null;
      final uri = base.replace(
        path:
            '${base.path.replaceFirst(RegExp(r'/+$'), '')}/${a.longitude},${a.latitude};${b.longitude},${b.latitude}',
        queryParameters: {'overview': 'false', 'steps': 'false'},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = result['routes'] as List?;
      if (result['code'] != 'Ok' || routes == null || routes.isEmpty)
        return null;
      final route = routes.first as Map;
      final km = (route['distance'] as num).toDouble() / 1000;
      final seconds = (route['duration'] as num).toDouble();
      if (!km.isFinite || !seconds.isFinite || km <= 0 || seconds <= 0)
        return null;
      return (distanceKm: km, durationMinutes: (seconds / 60).ceil());
    } catch (_) {
      return null;
    }
  }
}
