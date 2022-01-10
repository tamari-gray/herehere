import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:cysm/controllers/game_controller.dart';
import 'package:cysm/controllers/location_controller.dart';
import 'package:cysm/models/game.dart';
import 'package:cysm/models/player.dart';

class CompassForTagger extends StatelessWidget {
  final GameController _gameController = Get.find();
  final LocationController _locationController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Obx(() {
        final _userBearing = _locationController.userBearing.value.heading!;
        final _userLocation = _locationController.location.value;

        // handle hiders
        final _hidersRemaining = _gameController.players
            .where((p) => !p.hasBeenTagged && !p.isTagger)
            .toList();

        final _unsafeHiders =
            _hidersRemaining.where((h) => !h.locationHidden).toList();

        final _hidersWithDistanceAndAngle =
            _gameController.hidersWithAngleAndDistance(
          _userLocation,
          _userBearing,
          _unsafeHiders,
        );

        final _foundHiders = _hidersWithDistanceAndAngle
            .where(
              (_hider) =>
                  _locationController
                      .isWithinFindingDistance(_hider.distanceFromUser) &&
                  !_hider.locationHidden,
            )
            .toList();
        _gameController.foundHiders.value = _foundHiders;
        final _gamePhase = _gameController.game.value.phase;

        return _gamePhase == gamePhase.counting
            ? NorthArrow()
            : Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                alignment: AlignmentDirectional.center,
                children: _foundHiders.isEmpty
                    ? [
                        if (_gamePhase == gamePhase.playing)
                          ...helperArrows(_hidersWithDistanceAndAngle),
                        NorthArrow(),
                      ]
                    : [FoundHiders(hiders: _foundHiders)],
              );
      }),
    );
  }

  List<HelperArrow> helperArrows(List<Hider> _hiders) {
    final _hidersAsHelperArrows = _hiders
        .map((_hider) => HelperArrow(
            angle: _hider.angleFromUser, distance: _hider.distanceFromUser))
        .toList();
    _hidersAsHelperArrows.sort((a, b) => b.distance!.compareTo(a.distance!));
    return _hidersAsHelperArrows;
  }
}

class FoundHiders extends StatelessWidget {
  const FoundHiders({
    required this.hiders,
  });

  final List<Player> hiders;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 50, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Found ${hiders.map((e) => e.username).join(",")} ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            Text(
              'tag them!',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Image.asset(
              'assets/swiper.jpeg',
              fit: BoxFit.scaleDown,
            ),
          ],
        ),
      ),
    );
  }
}

class NorthArrow extends StatelessWidget {
  final GameController _gameController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0,
      // angle: (bearing! * (pi / 360) * -2),       if want facing north
      child: _gameController.game.value.phase == gamePhase.counting
          ? Image.asset(
              'assets/niira_compass_basic.png',
              width: 155,
              height: 155,
            )
          : Image.asset(
              'assets/niira_compass_basic.png',
              fit: BoxFit.scaleDown,
              width: 75,
              height: 75,
            ),
    );
  }
}

class HelperArrow extends StatelessWidget {
  const HelperArrow({
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
      bottom: 310,
      child: Transform.rotate(
        angle: angleInRadians,
        origin: Offset(0, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${distance!} m',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
