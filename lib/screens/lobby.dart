import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/player_controller.dart';

class Lobby extends StatelessWidget {
  final PlayerController _playerController = Get.find();
  final GameController _gameController = Get.put(GameController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _playerController.hasLoggedIn.value = false;
          _playerController.isAdmin.value = false;
        },
        label: Text('log out'),
      ),
      body: Obx(() {
        if (_gameController.phase.value == gamePhase.initialising) {
          return _playerController.isAdmin.value
              ? Container(
                  child: Center(
                    child: Text('admin in lobby'),
                  ),
                )
              : Container(
                  child: Center(
                    child: Text('waiting for game to start'),
                  ),
                );
        } else if (_gameController.phase.value == gamePhase.playing) {
          return Container(
            child: Center(
              child: Text('playing game screen'),
            ),
          );
        } else if (_gameController.phase.value == gamePhase.finished) {
          return Container(
            child: Center(
              child: Text('finished game screen'),
            ),
          );
        } else {
          return Container(
            child: Center(
              child: Text('error loading game screen'),
            ),
          );
        }
      }),
    );
  }
}
