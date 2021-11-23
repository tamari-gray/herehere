import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/user_controller.dart';

class LocationHiddenBanner extends StatelessWidget {
  final UserController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(Icons.check),
      label: Obx(() {
        return Text(
            'Location safe for ${_userController.locationHiddenTimer.value}s');
      }),
    );
  }
}

class LocationNotSafeBanner extends StatelessWidget {
  const LocationNotSafeBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Get.defaultDialog(
            title: 'Tagger knows where you are!',
            middleText:
                'Use compass to find safety items, theyll keepyour location hidden from the tagger for 90 seconds!',
            textConfirm: 'Ok',
            onConfirm: () async {
              Get.back();
            });
      },
      icon: Icon(Icons.help),
      label: Text('Location not safe'),
    );
  }
}

class PlayersRemaining extends StatelessWidget {
  const PlayersRemaining({
    Key? key,
    required GameController gameController,
  })  : _gameController = gameController,
        super(key: key);

  final GameController _gameController;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: Obx(
        () => Text(
          '${_gameController.hidersRemaining()} hiders left',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      style: ButtonStyle(),
      onPressed: () {},
    );
  }
}

class PickingUpItem extends StatelessWidget {
  const PickingUpItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
            child: Text(
              'Picking Up item...',
              style: TextStyle(fontSize: 22),
            )),
      ),
    );
  }
}

class TaggingPlayer extends StatelessWidget {
  const TaggingPlayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
            child: Text(
              'Tagging player...',
              style: TextStyle(fontSize: 22),
            )),
      ),
    );
  }
}
