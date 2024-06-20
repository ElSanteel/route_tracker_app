import 'package:route_tracker_app/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_app/utils/google_maps_place_service.dart';
import 'package:route_tracker_app/utils/location_service.dart';
import 'package:route_tracker_app/utils/routes_service.dart';

class MapServices {
  PlacesService placesService = PlacesService();
  LocationService locationService = LocationService();
  RoutesService routesService = RoutesService();

  getPredictions(
      {required String input, required String sessionToken,required List<PlaceAutocompleteModel>places})async{
        
      // if the text field is not empty then make a request to the google maps places service
      if (input.isNotEmpty) {
        var result = await placesService.getPredictions(
            sessionToken: sessionToken, input: input);
        places.clear();
        places.addAll(result);
      } else {
        places.clear();
      }
      }
}
