import 'dart:convert';

import 'package:route_tracker_app/models/location_info/location_info.dart';
import 'package:route_tracker_app/models/routes_model/routes_model.dart';
import 'package:http/http.dart' as http;
import 'package:route_tracker_app/models/routes_modifier.dart';

class RoutesService {
  final String baseUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = 'AIzaSyBmhDvQXo3iFJt-j0v9VrgEihwFU6_Qa1E';

  Future<RoutesModel> fetchRoutes(
      {required LocationInfo origin,
      required LocationInfo destination,
      RoutesModifier? routeModifiers}) async {
    Uri url = Uri.parse(baseUrl);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
    };
    Map<String, dynamic> body = {
      "origin": origin.toJson(),
      "destination": destination.toJson(),
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": routeModifiers != null
          ? routeModifiers.toJson()
          : RoutesModifier().toJson(),
      "languageCode": "en-US",
      "units": "IMPERIAL"
    };

    var response = await http.post(url, headers: headers, body: body);
    if(response.statusCode == 200) {
      return RoutesModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('No routes found');
    }
  }
}
