import 'package:cysm/controllers/user_controller.dart';
import 'package:cysm/screens/game_screens/playing_game/compass/helper_arrow.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:cysm/controllers/game_controller.dart';
import 'package:cysm/controllers/location_controller.dart';
import 'package:cysm/models/game.dart';
import 'package:cysm/models/safety_item.dart';

import 'compass_for_tagger.dart';

class CompassForHider extends StatelessWidget {
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

        // handle items
        if (_gameController.game.value.generatingItems.generating &&
            !_gameController.itemRespawnTimerIsGoing.value) {
          _gameController.startItemRespawnTimer();
        }

        if (!_gameController.game.value.generatingItems.generating)
          _gameController.stopItemRespawnTimer();

        final _items = _gameController.items;
        final _itemsWithDistanceAndAngle =
            _gameController.itemsWithAngleAndDistance(
          _userLocation,
          _userBearing,
          _items,
        );
        final _foundItems = _itemsWithDistanceAndAngle
            .where((_item) =>
                _locationController.isWithinFindingDistance(_item.distance))
            .toList();

        _gameController.foundItems.value = _foundItems;

        final _gamePhase = _gameController.game.value.phase;
        return _gamePhase == gamePhase.counting
            ? Column(children: [
                NorthArrow(),
                Center(
                  child: Text('waiting for tagger to finish counting...'),
                )
              ])
            : Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                alignment: AlignmentDirectional.center,
                children: _foundItems.isNotEmpty
                    ? [FoundItems(items: _foundItems)]
                    : [
                        if (_gamePhase == gamePhase.playing)
                          ...helperArrows(_itemsWithDistanceAndAngle),
                        _items.isNotEmpty
                            ? NorthArrow()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      'Safety items respawning in: ${_gameController.itemRespawnTime.value}',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                      ],
              );
      }),
    );
  }

  List<HelperArrow> helperArrows(List<SafetyItem> _items) {
    final _itemsAsHelperArrows = _items
        .map((_item) =>
            HelperArrow(angle: _item.angleFromUser, distance: _item.distance))
        .toList();
    _itemsAsHelperArrows.sort((a, b) => b.distance!.compareTo(a.distance!));
    return _itemsAsHelperArrows;
  }
}

class FoundItems extends StatelessWidget {
  const FoundItems({
    required this.items,
  });

  final List<SafetyItem> items;

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
              'Found ${items.length} items!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            Text(
              'pick them up!',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Image.asset(
              'assets/crystal_.png',
              fit: BoxFit.scaleDown,
            ),
          ],
        ),
      ),
    );
  }
}

class ItemTimer extends StatelessWidget {
  final GameController _gameController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0,
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
