import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/utils/location_service.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initalCameraPosition;
  // initialize the location service and make it late to initialize it later
  late LocationService locationService;

  @override
  void initState() {
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    // initialize the location service
    locationService = LocationService();
    // update the current location
    updateCurrentLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      zoomControlsEnabled: false,
      initialCameraPosition: initalCameraPosition,
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
    } on LocationServiceException catch (e) {
      // TODO: handle the exception
    } on LocationPermissionException catch (e) {
      // TODO: handle the exception
    } catch (e) {
      // TODO: handle the exception
    }
  }
}

// steps to get the user location
// inquire about location service or check if location service is enabled or not ?  --> done
// request permission --> done
// get location
// display

// world view 0 -> 3
// country view 4-> 6
// city view 10 -> 12
// street view 13 -> 17
// building view 18 -> 20
