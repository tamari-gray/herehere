import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:niira2/services/database.dart';

class LocationController extends GetxController {
  final Database _database = Get.find();

  var location = Position.fromMap({'latitude': 0.0, 'longitude': 0.0}).obs;
  var serviceEnabled = false.obs;
  var locationPermission = LocationPermission.denied.obs;

  late StreamSubscription<Position> positionStream;

  updateLocationInDb(String userId) async {
    ever(location, (_) => _database.updateUserLocation(userId, location.value));
  }

  stopUpdatingLocationInDb(String userId) {
    positionStream.cancel();
  }

  Future<GeoPoint> getLocationAsGeopoint() async {
    final _location = await Geolocator.getCurrentPosition();

    return GeoPoint(_location.latitude, _location.longitude);
  }

  void listenToLocation() {
    positionStream = Geolocator.getPositionStream(
      distanceFilter: 1,
      intervalDuration: Duration(seconds: 1),
    ).listen((event) {
      location = event.obs;
    });
  }

  bool distanceBetween(Position _itemOrHider) {
    final _distance = Geolocator.distanceBetween(
      location.value.latitude,
      location.value.longitude,
      _itemOrHider.latitude,
      _itemOrHider.longitude,
    ).floor();
    return _distance <= 10.5 ? true : false;
  }
}
