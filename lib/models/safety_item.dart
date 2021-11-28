import 'package:geolocator/geolocator.dart';

class SafetyItem {
  String id = '';
  Position location = Position.fromMap({'latitude': 1.0, 'longitude': 0.0});
  int distance = 0;
  double angleFromUser = 0;

  SafetyItem(
    this.id,
    this.location,
  );

  SafetyItem.fromDefault() {
    id = '';
    location = Position.fromMap({'latitude': 1.0, 'longitude': 0.0});
  }
}
