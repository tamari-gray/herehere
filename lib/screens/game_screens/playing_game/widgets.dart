import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cysm/controllers/game_controller.dart';
import 'package:cysm/controllers/user_controller.dart';

class LocationHiddenBanner extends StatelessWidget {
  final UserController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xff82fab8)),
      ),
      onPressed: () {},
      icon: Icon(
        Icons.check,
        color: Colors.black,
      ),
      label: Obx(() {
        return Text(
          'Location safe for ${_userController.locationHiddenTimer.value}s',
          style: TextStyle(color: Colors.black),
        );
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

class HidersRemaining extends StatelessWidget {
  final GameController _gameController = Get.find();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: Obx(
        () => Text(
          '${_gameController.hidersRemaining().length} hiders left',
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
