import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:cysm/controllers/game_controller.dart';
import 'package:cysm/models/game.dart';
import 'package:cysm/screens/lobby.dart';
import 'package:cysm/screens/game_screens/playing_game/playing_game_screen.dart';

class JoinedGame extends StatefulWidget {
  @override
  State<JoinedGame> createState() => _JoinedGameState();
}

class _JoinedGameState extends State<JoinedGame> {
  final GameController _gameController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _phase = _gameController.game.value.phase;
      if (_phase == gamePhase.creating) {
        return Lobby();
      } else if (_phase == gamePhase.counting || _phase == gamePhase.playing) {
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
