import 'package:route_tracker_app/models/routes_model/routes_model.dart';
import 'package:http/http.dart' as http;

class RoutesService {
  Future<RoutesModel> fetchRoutes() {
    final String baseUrl =
        'https://routes.googleapis.com/directions/v2:computeRoutes';
    final String apiKey = 'AIzaSyBmhDvQXo3iFJt-j0v9VrgEihwFU6_Qa1E';
  }
}
