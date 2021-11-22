import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/models/safety_item.dart';

class Compass extends StatelessWidget {
  final GameController _gameController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: Center(
        child: Builder(builder: (context) {
          return Column(
            children: <Widget>[
              _buildCompass(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text('loading compass'),
              ],
            ),
          );
        }

        double? deviceHeading = snapshot.data!.heading;

        if (deviceHeading == null)
          return Center(
            child: Text(
                "Device does not have sensors!, tam, this phone cant play niira"),
          );

        return Container(
          width: 500,
          height: 300,
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: Obx(() {
            return Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.center,
              children: [
                if (_gameController.game.value.phase == gamePhase.playing)
                  ...helperArrows(deviceHeading),
                NorthArrow(bearing: 0),
              ],
            );
          }),
        );
      },
    );
  }

  List<ItemArrow> helperArrows(double deviceHeading) {
    final GameController _gameController = Get.find();
    final LocationController _locationController = Get.find();
    final UserController _userController = Get.find();

    final _playerLocation = _locationController.location;

    if (_userController.user.value.isTagger) {
      final _unsafeHiders =
          _gameController.players.where((_player) => !_player.locationHidden);

      return _unsafeHiders.map((Player _hider) {
        final double _bearing = Geolocator.bearingBetween(
          _hider.location.latitude,
          _hider.location.longitude,
          _playerLocation.value.latitude,
          _playerLocation.value.longitude,
        );

        final int _distance = Geolocator.distanceBetween(
          _playerLocation.value.latitude,
          _playerLocation.value.longitude,
          _hider.location.latitude,
          _hider.location.longitude,
        ).floor();

        return calcBearing(_bearing, deviceHeading, _distance);
      }).toList();
    } else {
      // ignore: invalid_use_of_protected_member
      return _gameController.items.value.map((SafetyItem _item) {
        final double _bearing = Geolocator.bearingBetween(
          _item.latitude,
          _item.longitude,
          _playerLocation.value.latitude,
          _playerLocation.value.longitude,
        );

        // print(
        //     'lat ${_playerLocation.value.latitude}, ln ${_playerLocation.value.longitude}');

        final int _distance = Geolocator.distanceBetween(
          _playerLocation.value.latitude,
          _playerLocation.value.longitude,
          _item.latitude,
          _item.longitude,
        ).floor();

        return calcBearing(_bearing, deviceHeading, _distance);
      }).toList();
    }
  }

  ItemArrow calcBearing(double _bearing, double deviceHeading, int _distance) {
    if (_bearing < 180) {
      final deltaAngle = (deviceHeading - _bearing) + 180;
      if (deltaAngle < 0) {
        return ItemArrow(
          angle: deltaAngle + 360.0,
          distance: _distance,
        );
      } else {
        return ItemArrow(
          angle: deltaAngle,
          distance: _distance,
        );
      }
    } else {
      final angle = (deviceHeading - _bearing);
      if (angle < 0) {
        return ItemArrow(
          angle: angle + 360.0,
          distance: _distance,
        );
      } else {
        return ItemArrow(
          angle: angle,
          distance: _distance,
        );
      }
    }
  }
}

class FoundSafetyItems extends StatelessWidget {
  FoundSafetyItems({Key? key});
  final GameController _gameController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 50, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              final _items = _gameController.getFoundSafetyItems();
              return Text(
                '${_items.length} SAFETY ITEM${_items.length > 1 ? 'S' : ''} FOUND',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              );
            }),
            Text(
              'Pick me up!',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Image.asset(
              'assets/crystal_.png',
              fit: BoxFit.scaleDown,
              // width: 100,
              // height: 100,
            ),
          ],
        ),
      ),
    );
  }
}

class FoundHiders extends StatelessWidget {
  final GameController _gameController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 50, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              final _hiders = _gameController.getFoundHiders();
              return Text(
                'Found ${_hiders.map((e) => e.username).join(",")} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              );
            }),
            Text(
              'tag them!',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Image.asset(
              'assets/swiper.jpeg',
              fit: BoxFit.scaleDown,
              // width: 100,
              // height: 100,
            ),
          ],
        ),
      ),
    );
  }
}

class NorthArrow extends StatelessWidget {
  const NorthArrow({
    Key? key,
    required this.bearing,
  }) : super(key: key);
  final double? bearing;
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0,
      // angle: (bearing! * (pi / 360) * -2),
      child: Image.asset(
        'assets/niira_compass_basic.png',
        fit: BoxFit.scaleDown,
        width: 75,
        height: 75,
      ),
    );
  }
}

class ItemArrow extends StatelessWidget {
  const ItemArrow({
    Key? key,
    required this.angle,
    required this.distance,
  }) : super(key: key);

  final double? angle;
  final int? distance;

  @override
  Widget build(BuildContext context) {
    final angleInRadians = (angle! * (pi / 360) * -2);
    return Positioned(
      bottom: 210,
      child: Transform.rotate(
        angle: angleInRadians,
        origin: Offset(0, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${distance!} m',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
              child: Image.asset(
                'assets/arrow_niira_sm.png',
                width: 50,
                height: 70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
