import 'package:geolocator/geolocator.dart';

class SafetyItem {
  Position location = Position.fromMap({});
  bool pickedUp = false;
  double size = 5; // diameter in metres
}
