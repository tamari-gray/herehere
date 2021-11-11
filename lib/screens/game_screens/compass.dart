import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/models/safety_item.dart';

class Compass extends StatefulWidget {
  const Compass({
    Key? key,
  }) : super(key: key);

  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Column(
        children: <Widget>[
          _buildCompass(),
        ],
      );
    });
  }

  Widget _buildCompass() {
    final GameController _gameController = Get.find();
    final LocationController _locationController = Get.find();

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
        final deviceHEadingInRadians = (deviceHeading! * (pi / 180) * 1);
        print(
            'north bearing: $deviceHeading, in radians: $deviceHEadingInRadians');

        // if deviceHeading is null, then device does not support this sensor
        // show error message
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
                ..._gameController.items.map((SafetyItem _item) {
                  final _playerLocation = _locationController.location;

                  final double _bearing = Geolocator.bearingBetween(
                    _item.latitude,
                    _item.longitude,
                    _playerLocation.value.latitude,
                    _playerLocation.value.longitude,
                  );

                  // print('bearing between: $_bearing');
                  // print(
                  //     'lat ${_playerLocation.value.latitude}, ln ${_playerLocation.value.longitude}');

                  final int _distance = Geolocator.distanceBetween(
                    _playerLocation.value.latitude,
                    _playerLocation.value.longitude,
                    _item.latitude,
                    _item.longitude,
                  ).floor();

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
                }).toList(),
                NorthArrow(bearing: deviceHeading),
              ],
            );
          }),
        );
      },
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
      angle: (bearing! * (pi / 360) * -2),
      child: Image.asset(
        'assets/niira_compass_basic.png',
        fit: BoxFit.scaleDown,
        width: 100,
        height: 100,
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
    print('hi $angle, $angleInRadians');
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
