import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/screens/lobby.dart';
import 'package:niira2/screens/game_screens/playing_game/playing_game_screen.dart';
import 'package:niira2/utilities/placing.dart';

class JoinedGame extends StatefulWidget {
  @override
  State<JoinedGame> createState() => _JoinedGameState();
}

class _JoinedGameState extends State<JoinedGame> {
  final UserController _userController = Get.find();
  final GameController _gameController = Get.find();
  final LocationController _locationController = Get.find();

  @override
  void initState() {
    super.initState();
    _locationController.listenToLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _phase = _gameController.game.value.phase;
      if (_phase == gamePhase.creating) {
        return Lobby();
      } else if (_phase == gamePhase.counting ||
          _phase == gamePhase.playing &&
              !_userController.user.value.hasBeenTagged) {
        return PlayingGameScreen();
      } else {
        return Container(
          child: Center(
            child: Text('error loading game screen'),
          ),
        );
      }
    });
  }
}

class FinishedGameScreen extends StatelessWidget {
  const FinishedGameScreen({
    Key? key,
    required int placing,
  })  : _placing = placing,
        super(key: key);

  final int _placing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('You came ${placing(_placing)}'),
        ),
      ),
    );
  }
}

class PlayerWaitingForGameToStart extends StatelessWidget {
  final UserController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _userController.user.value.isAdmin = false;
          _userController.user.value.isAdmin = false;
        },
        label: Text('log out'),
      ),
      body: Container(
        child: Center(
          child: Text('Player in lobby'),
        ),
      ),
    );
  }
}
