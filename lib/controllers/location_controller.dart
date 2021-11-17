import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:niira2/services/database.dart';

class LocationController extends GetxController {
  var location = Position.fromMap({'latitude': 0.0, 'longitude': 0.0}).obs;
  var serviceEnabled = false.obs;
  var locationPermission = LocationPermission.denied.obs;
  final Database _database = Get.find();

  StreamSubscription<Position> positionStream =
      StreamSubscription as StreamSubscription<Position>;

  updateLocationInDb(String userId) async {
    ever(location, (_) => _database.updateUserLocation(userId, location.value));
  }

  stopUpdatingLocationInDb(String userId) {
    positionStream.cancel();
  }

  void listenToLocation() {
    positionStream = Geolocator.getPositionStream(
      distanceFilter: 1,
      intervalDuration: Duration(seconds: 1),
    ).listen((event) {
      location = event as Rx<Position>;
    });
  }
}
