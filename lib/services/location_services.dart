import 'package:location/location.dart';

class LocationServices {
  Location location = Location();
  late LocationData _locData;

  Future<void> initialize() async {
    bool _serviceEnabled;
    PermissionStatus _permissions;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        return;
      }
    }

    _permissions = await location.hasPermission();
    if (_permissions == PermissionStatus.denied) {
      _permissions = await location.requestPermission();
      if (_permissions != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<double?> getLatitude() async {
    _locData = await location.getLocation();
    return _locData.latitude;
  }

  Future<double?> getLongitude() async {
    _locData = await location.getLocation();
    return _locData.longitude;
  }

}