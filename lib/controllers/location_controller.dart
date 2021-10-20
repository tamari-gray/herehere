import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationController extends GetxController {
  final location = Position.fromMap({'latitude': 0.0, 'longitude': 0.0}).obs;
  var serviceEnabled = false.obs;
  var locationPermission = LocationPermission.denied.obs;

  void listenToLocation() {
    location.bindStream(Geolocator.getPositionStream());
  }
}
