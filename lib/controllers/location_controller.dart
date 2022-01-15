import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cysm/services/database.dart';

class LocationController extends GetxController {
  final Database _database = Get.find();

  var location = Position.fromMap({'latitude': 0.0, 'longitude': 0.0}).obs;
  var serviceEnabled = false.obs;
  var locationPermission = LocationPermission.denied.obs;
  var userBearing = CompassEvent.fromList([1, 2, 3]).obs;
  var locationAccuracy = LocationAccuracyStatus.reduced.obs;

  late StreamSubscription<Position> positionStream;
  late Stream<CompassEvent> userBearingStream;

  updateLocationInDb(String userId) async {
    ever(location, (_) => _database.updateUserLocation(userId, location.value));
  }

  stopUpdatingLocationInDb(String userId) {
    positionStream.cancel();
  }

  listenToPLayerBearing() {
    userBearing.bindStream(FlutterCompass.events!);
  }

  Future<GeoPoint> getLocationAsGeopoint() async {
    final _location = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    return GeoPoint(_location.latitude, _location.longitude);
  }

  Future<LocationAccuracyStatus> getLocationAccuracy() async =>
      await Geolocator.getLocationAccuracy();

  void listenToLocation() {
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      // distanceFilter: 1,
      // intervalDuration: Duration(seconds: 1),
    ).listen((event) {
      location = event.obs;
    });
  }

  bool isWithinFindingDistance(int _distance) {
    return _distance <= 3 ? true : false;
  }

  int distanceFromUser(Position _playerOrItemLoc) {
    return Geolocator.distanceBetween(
      location.value.latitude,
      location.value.longitude,
      _playerOrItemLoc.latitude,
      _playerOrItemLoc.longitude,
    ).floor();
  }

  double bearingBetween(Position _playerOrItemLoc) {
    return Geolocator.bearingBetween(
      _playerOrItemLoc.latitude,
      _playerOrItemLoc.longitude,
      location.value.latitude,
      location.value.longitude,
    );
  }

  double angleFromUser(Position _playerOrItemLoc) {
    final _bearingBetween = bearingBetween(_playerOrItemLoc);
    if (_bearingBetween < 180) {
      final deltaAngle = (userBearing.value.heading! - _bearingBetween) + 180;
      if (deltaAngle < 0) {
        return deltaAngle + 360.0;
      } else {
        return deltaAngle;
      }
    } else {
      final angle = (userBearing.value.heading! - _bearingBetween);
      if (angle < 0) {
        return angle + 360.0;
      } else {
        return angle;
      }
    }
  }
}
