import 'package:route_tracker_app/models/routes_model/routes_model.dart';
import 'package:http/http.dart' as http;

class RoutesService {
  final String baseUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = 'AIzaSyBmhDvQXo3iFJt-j0v9VrgEihwFU6_Qa1E';

  Future<RoutesModel> fetchRoutes({}) {
    Uri url =Uri.parse(baseUrl);
    Map<String,String> header={
      'Content-Type':'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
    };
    Map<String,dynamic>body= {
      "origin":{
    "location":{
      "latLng":{
        "latitude": 37.419734,
        "longitude": -122.0827784
      }
    }
  },
  "destination":{
    "location":{
      "latLng":{
        "latitude": 37.417670,
        "longitude": -122.079595
      }
    }
  },
  "travelMode": "DRIVE",
  "routingPreference": "TRAFFIC_AWARE",
  "departureTime": "2023-10-15T15:01:23.045123456Z",
  "computeAlternativeRoutes": false,
  "routeModifiers": {
    "avoidTolls": false,
    "avoidHighways": false,
    "avoidFerries": false
  },
  "languageCode": "en-US",
  "units": "IMPERIAL"
};
  }
}
