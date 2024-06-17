import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_app/utils/google_maps_place_service.dart';
import 'package:route_tracker_app/utils/location_service.dart';
import 'package:route_tracker_app/widgets/custom_list_view.dart';
import 'package:route_tracker_app/widgets/custom_text_field.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late GoogleMapsPlacesService googleMapsPlacesService;
  late CameraPosition initalCameraPosition;
  // initialize the location service and make it late to initialize it later
  late LocationService locationService;
  late TextEditingController textEditingController;

  // initialize the google map controller and make it late to initialize it later
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  List<PlaceAutocompleteModel> places = [];

  @override
  void initState() {
    googleMapsPlacesService = GoogleMapsPlacesService();
    textEditingController = TextEditingController();
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    // initialize the location service
    locationService = LocationService();
    fetchPredictions();

    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      if (textEditingController.text.isNotEmpty) {
        var result = await googleMapsPlacesService.getPredictions(
            input: textEditingController.text);
        places.clear();
        places.addAll(result);
        setState(() {});
      } else {
        places.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
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
        ),
        Positioned(
          top: 20,
          left: 25,
          right: 25,
          child: Column(
            children: [
              CustomTextField(
                textEditingController: textEditingController,
              ),
              const SizedBox(
                height: 16,
              ),
              CustomListView(places: places)
            ],
          ),
        ),
      ],
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


// steps to display places on the map

// create text field and takes input from it
// listen to the text field
// search place
// make request each time input changes ( google maps places service)
// display list of results (places)

// steps to build the route tracker app
// text field => search place
// create route

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
