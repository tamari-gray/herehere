import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cysm/controllers/user_controller.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cysm/services/database.dart';

class LocationController extends GetxController {
  final Database _database = Get.find();
  final UserController _userController = Get.find();

  var location = Position.fromMap({'latitude': 0.5, 'longitude': 0.5}).obs;
  var serviceEnabled = false.obs;
  var locationPermission = LocationPermission.denied.obs;
  var userBearing = CompassEvent.fromList([1, 2, 3]).obs;
  var locationAccuracy = LocationAccuracyStatus.precise.obs;

  late StreamSubscription<Position> positionStream;
  late Stream<CompassEvent> userBearingStream;

  // updateLocationInDb(String userId) async {
  //   ever(location, (_) => _database.updateUserLocation(userId, location.value));
  // }

  checkLocationSettings() async {
    serviceEnabled.value = await Geolocator.isLocationServiceEnabled();
    locationPermission.value = await Geolocator.requestPermission();
    locationAccuracy.value = await Geolocator.getLocationAccuracy();
  }

  stopUpdatingLocationInDb(String userId) {
    positionStream.cancel();
  }

  listenToPLayerBearing() {
    userBearing.bindStream(FlutterCompass.events!);
  }

  Future<GeoPoint> getLocationData() async {
    listenToLocation();

    final _location = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    return GeoPoint(_location.latitude, _location.longitude);
  }

  Future<LocationAccuracyStatus> getLocationAccuracy() async =>
      await Geolocator.getLocationAccuracy();

  void listenToLocation() {
    positionStream = Geolocator.getPositionStream(
      locationSettings:
          LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
    ).listen((event) {
      final userId = _userController.userId.value;
      if (userId != "") _database.updateUserLocation(userId, event);
    });
  }

  // checks if item or hider is within 8m radius
  bool isWithinFindingDistance(int _distance) {
    return _distance <= 15 ? true : false;
  }

  int distanceFromUser(
    Position _userLoc,
    Position _playerOrItemLoc,
  ) {
    return Geolocator.distanceBetween(
      _userLoc.latitude,
      _userLoc.longitude,
      _playerOrItemLoc.latitude,
      _playerOrItemLoc.longitude,
    ).floor();
  }

  double bearingBetween(Position _userLoc, Position _playerOrItemLoc) {
    return Geolocator.bearingBetween(
      _userLoc.latitude,
      _userLoc.longitude,
      _playerOrItemLoc.latitude,
      _playerOrItemLoc.longitude,
    );
    // final _geoPlayerOrItemLoc =
    //     LatLng(_playerOrItemLoc.latitude, _playerOrItemLoc.longitude);
    // final _playerLoc = LatLng(_userLoc.latitude, _userLoc.longitude);

    // return finalBearingBetweenTwoGeoPoints(_geoPlayerOrItemLoc, _playerLoc)
    //     .toDouble();
  }

  double angleFromUser(Position _userLoc, Position _playerOrItemLoc) {
    final _bearingBetween = bearingBetween(_userLoc, _playerOrItemLoc);
    final _userHeading = userBearing.value.heading;
    final deltaAngle = (_userHeading! - _bearingBetween);

    return deltaAngle;

    // if (_bearingBetween < 180) {
    //   final deltaAngle = (_userHeading! - _bearingBetween) + 180;
    //   if (deltaAngle < 0) {
    //     return deltaAngle + 360.0;
    //   } else {
    //     return deltaAngle;
    //   }
    // } else {
    //   final angle = (userBearing.value.heading! - _bearingBetween);
    //   if (angle < 0) {
    //     return angle + 360.0;
    //   } else {
    //     return angle;
    //   }
    // }
  }
}

class LatLng {
  double lat = 0;
  double lng = 0;
  LatLng(this.lat, this.lng);
}

/// calculate the bearing from point l1 to point l2
num bearingBetweenTwoGeoPoints(LatLng l1, LatLng l2) {
  num l1LatRadians = degreesToRadians(l1.lat);
  num l2LatRadians = degreesToRadians(l2.lat);
  num lngRadiansDiff = degreesToRadians(l2.lng - l1.lng);
  num y = sin(lngRadiansDiff) * cos(l2LatRadians);
  num x = cos(l1LatRadians) * sin(l2LatRadians) -
      sin(l1LatRadians) * cos(l2LatRadians) * cos(lngRadiansDiff);
  num radians = atan2(y, x);

  return (radiansToDegrees(radians) + 360) % 360;
}

/// calculate the final bearing from point l1 to point l2
num finalBearingBetweenTwoGeoPoints(LatLng l1, LatLng l2) {
  return (bearingBetweenTwoGeoPoints(l2, l1) + 180) % 360;
}

/// convert degrees to radians
num degreesToRadians(num degrees) {
  return degrees * pi / 180;
}

/// convert degrees to radians
num radiansToDegrees(num radians) {
  return radians * 180 / pi;
}
