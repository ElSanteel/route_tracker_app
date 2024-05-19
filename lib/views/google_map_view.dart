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

  // initialize the google map controller and make it late to initialize it later
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    // initialize the location service
    locationService = LocationService();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      zoomControlsEnabled: false,
      initialCameraPosition: initalCameraPosition,
      // onMapCreated callback to get the google map controller
      onMapCreated: (controller) {
        // assign the google map controller to the googleMapController
        googleMapController = controller;
        // we have put updateCurrentLocation here to make sure that the googleMapController is initialized
        updateCurrentLocation();
      },
      markers: markers,
    );
  }

  void updateCurrentLocation() async {
    try {
      // get the location data
      var locationData = await locationService.getLocation();
      // create a new LatLng object with the location data
      LatLng currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
          markerId: const MarkerId('my location'), position: currentPosition);
      // update the camera position
      CameraPosition myCameraPosition =
          CameraPosition(target: currentPosition, zoom: 16);
      // animate the camera to the new position
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(myCameraPosition));
      // add the marker to the markers set
      markers.add(currentLocationMarker);
      // update the state
      setState(() {});
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
