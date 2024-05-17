import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  // step 1 : method to check if location service is enabled or not
  Future<bool> checkAndRequestLocationService() async {
    // check if location service is enabled or not
    var isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      // request location service
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        return false;
      }
    }
    return true;
  }

  // step 2 : method to check if location permission is granted or not
  Future<bool> checkAndRequestLocationPermission() async {
    // check if location permission is granted or not
    var permissionStatus = await location.hasPermission();
    // check if the permission is denied forever
    if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    }
    // check if the permission is denied
    if (permissionStatus == PermissionStatus.denied) {
      // request location permission
      permissionStatus = await location.requestPermission();
      // checking the permission status ( way one )
      return permissionStatus == PermissionStatus.granted;
    }
    // return true if the permission is granted and the user allowed the permission
    return true;
  }

  // notice here in this commit we don't need this method now cuz we don't want a stream of data
  void getRealTimeLocationData(void Function(LocationData)? onData) {
    location.onLocationChanged.listen(onData);
  }

  // step 3 : method to get the location data
  Future<LocationData> getLocation() async {
    return await location.getLocation();
  }
}
