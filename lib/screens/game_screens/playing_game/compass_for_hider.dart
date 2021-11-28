import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/safety_item.dart';

import 'compass_for_tagger.dart';

class CompassForHider extends StatelessWidget {
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
                        NorthArrow(),
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
