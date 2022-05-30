import 'package:cysm/controllers/user_controller.dart';
import 'package:cysm/screens/game_screens/playing_game/compass/helper_arrow.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:cysm/controllers/game_controller.dart';
import 'package:cysm/controllers/location_controller.dart';
import 'package:cysm/models/game.dart';
import 'package:cysm/models/player.dart';

class CompassForTagger extends StatelessWidget {
  final GameController _gameController = Get.find();
  final LocationController _locationController = Get.find();
  final UserController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Obx(() {
        final _userLocation = _userController.user.value.location;
        final _userBearing = _locationController.userBearing.value.heading!;

        // handle hiders
        final _hidersRemaining = _gameController.players
            .where((p) => !p.hasBeenTagged && !p.isTagger)
            .toList();

        final _allHidersWithDistanceAndAngle =
            _gameController.hidersWithAngleAndDistance(
          _userLocation,
          _userBearing,
          _hidersRemaining,
        );

        final _unsafeHiders = _allHidersWithDistanceAndAngle
            .where((h) => !h.locationHidden)
            .toList();

        final _foundHiders = _allHidersWithDistanceAndAngle
            .where(
              (_hider) => _locationController
                  .isWithinFindingDistance(_hider.distanceFromUser),
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
                    ? _unsafeHiders.isEmpty
                        ? [
                            // if hiders arent in finding distance and all have safety items
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Text(
                                    'All hiders locations are safe, for now...',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ]),
                            NorthArrow(),
                          ]
                        : [
                            if (_gamePhase == gamePhase.playing)
                              ...helperArrows(_unsafeHiders),
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
