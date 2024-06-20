import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_app/utils/location_service.dart';
import 'package:route_tracker_app/utils/map_services.dart';
import 'package:route_tracker_app/widgets/custom_list_view.dart';
import 'package:route_tracker_app/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initalCameraPosition;
  late MapServices mapServices;
  late TextEditingController textEditingController;

  // initialize the google map controller and make it late to initialize it later
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  List<PlaceAutocompleteModel> places = [];
  Set<Polyline> polylines = {};

  // initialize the uuid
  late Uuid uuid;
  // initialize the session token
  String? sessionToken;

  late LatLng currentLocation;
  late LatLng desination;

  Timer? debounce;

  @override
  void initState() {
    mapServices = MapServices();

    // initialize the uuid
    uuid = const Uuid();

    textEditingController = TextEditingController();
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));

    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() {
      // if the debounce is active then cancel it
      if (debounce?.isActive ?? false) {
        debounce?.cancel();
      }

      // start the debounce
      debounce = Timer(const Duration(milliseconds: 100), () async {
        // if the session token is null then assign a new session token
        sessionToken ??= uuid.v4();
        await mapServices.getPredictions(
            input: textEditingController.text,
            sessionToken: sessionToken!,
            places: places);
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: polylines,
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
              CustomListView(
                places: places,
                mapServices: mapServices,
                onPlaceSelect: (placeDetailsModel) async {
                  textEditingController.clear();
                  places.clear();
                  sessionToken = null;
                  setState(() {});
                  desination = LatLng(
                      placeDetailsModel.geometry!.location!.lat!,
                      placeDetailsModel.geometry!.location!.lng!);

                  var points = await mapServices.getRouteData(
                      currentLocation: currentLocation, desination: desination);
                  mapServices.displayRoute(points,
                      polylines: polylines,
                      googleMapController: googleMapController);
                  setState(() {});
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      currentLocation = await mapServices.updateCurrentLocation(
          googleMapController: googleMapController, markers: markers);
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
