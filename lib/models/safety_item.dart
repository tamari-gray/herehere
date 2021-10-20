import 'package:location/location.dart';

class SafetyItem {
  LocationData location = LocationData.fromMap({'latitude': 0, 'longitude': 0});
  bool pickedUp = false;
  double size = 5; // in metres
}
