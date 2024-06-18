import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route_tracker_app/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_app/models/place_details_model/place_details_model.dart';
import 'package:route_tracker_app/utils/google_maps_place_service.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places,
    required this.googleMapsPlacesService,
    required this.onPlaceSelect,
  });

  final List<PlaceAutocompleteModel> places;
  final GoogleMapsPlacesService googleMapsPlacesService;
  final void Function(PlaceDetailsModel) onPlaceSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
              leading: const Icon(FontAwesomeIcons.mapMarkerAlt),
              title: Text(places[index].description!),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () async {
                  var placeDetails =
                      await googleMapsPlacesService.getPlaceDetails(
                          placeId: places[index].placeId.toString());
                  onPlaceSelect(placeDetails);
                },
              ));
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 0,
          );
        },
        itemCount: places.length,
      ),
    );
  }
}
