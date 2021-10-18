import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/screens/lobby.dart';
import 'package:niira2/screens/game_screens/playing_game_screen.dart';

class JoinedGame extends StatelessWidget {
  final UserController _userController = Get.find();
  final GameController _gameController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _phase = _gameController.game.value.phase;
      if (_phase == gamePhase.creating) {
        return Lobby();
      } else if (_phase == gamePhase.counting || _phase == gamePhase.playing) {
        return PlayingGameScreen();
      } else if (_phase == gamePhase.finished) {
        return _userController.user.value.isAdmin
            ? Container(
                child: Center(
                  child: Text('player finished game screen'),
                ),
              )
            : Container(
                child: Center(
                  child: Text('Admin finished game screen'),
                ),
              );
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
