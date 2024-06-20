import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/models/location_info/lat_lng.dart';
import 'package:route_tracker_app/models/location_info/location.dart';
import 'package:route_tracker_app/models/location_info/location_info.dart';
import 'package:route_tracker_app/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_app/models/routes_model/routes_model.dart';
import 'package:route_tracker_app/utils/google_maps_place_service.dart';
import 'package:route_tracker_app/utils/location_service.dart';
import 'package:route_tracker_app/utils/routes_service.dart';
import 'package:route_tracker_app/widgets/custom_list_view.dart';
import 'package:route_tracker_app/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late PlacesService placesService;
  late CameraPosition initalCameraPosition;
  // initialize the location service and make it late to initialize it later
  late LocationService locationService;
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

  late RoutesService routesService;
  late LatLng currentLocation;
  late LatLng desination;

  @override
  void initState() {
    // initialize the uuid
    uuid = const Uuid();

    placesService = PlacesService();
    textEditingController = TextEditingController();
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    // initialize the location service
    locationService = LocationService();
    routesService = RoutesService();

    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      // if the session token is null then assign a new session token
      sessionToken ??= uuid.v4();

      // if the text field is not empty then make a request to the google maps places service
      if (textEditingController.text.isNotEmpty) {
        var result = await placesService.getPredictions(
            sessionToken: sessionToken!, input: textEditingController.text);
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
                googleMapsPlacesService: placesService,
                onPlaceSelect: (placeDetailsModel) async {
                  textEditingController.clear();
                  places.clear();
                  sessionToken = null;
                  setState(() {});
                  desination = LatLng(
                      placeDetailsModel.geometry!.location!.lat!,
                      placeDetailsModel.geometry!.location!.lng!);

                  var points = await getRouteData();
                  displayRoute(points);
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
      // get the location data
      var locationData = await locationService.getLocation();

      // create a new LatLng object with the location data
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
          markerId: const MarkerId('my location'), position: currentLocation);
      // update the camera position
      CameraPosition myCameraPosition =
          CameraPosition(target: currentLocation, zoom: 16);
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

  Future<List<LatLng>> getRouteData() async {
    // create a new LocationInfoModel object with the current location
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        ),
      ),
    );

    // create a new LocationInfoModel object with the destination location
    LocationInfoModel destination = LocationInfoModel(
      location: LocationModel(
          latLng: LatLngModel(
        latitude: desination.latitude,
        longitude: desination.longitude,
      )),
    );

    RoutesModel routes = await routesService.fetchRoutes(
        origin: origin, destination: destination);

    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> points = getDecodedRoute(polylinePoints, routes);

    return points;
  }

  List<LatLng> getDecodedRoute(
      PolylinePoints polylinePoints, RoutesModel routes) {
    List<PointLatLng> result = polylinePoints.decodePolyline(
      routes.routes!.first.polyline!.encodedPolyline!,
    );

    List<LatLng> points =
        result.map((e) => LatLng(e.latitude, e.longitude)).toList();

    return points;
  }

  void displayRoute(List<LatLng> points) {
    Polyline route = Polyline(
      color: Colors.blue,
      width: 5,
      polylineId: const PolylineId('route'),
      points: points,
    );
    polylines.add(route);
    LatLngBounds bounds = getLatLngBounds(points);
    getLatLngBounds(points);
    googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 16));
    setState(() {});
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    var southWestLatitude = points.first.latitude;
    var southWestLongitude = points.first.longitude;
    var northEastLatitude = points.first.latitude;
    var northEastLongitude = points.first.longitude;

    for (var point in points) {
      southWestLatitude = min(southWestLatitude, point.latitude);
      southWestLongitude = min(southWestLongitude, point.longitude);
      northEastLatitude = max(northEastLatitude, point.latitude);
      northEastLongitude = max(northEastLongitude, point.longitude);
    }
    return LatLngBounds(
        southwest: LatLng(southWestLatitude, southWestLongitude),
        northeast: LatLng(northEastLatitude, northEastLongitude));
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
