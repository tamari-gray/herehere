import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/services/database.dart';
import 'package:marquee/marquee.dart';

class PlayingGameScreen extends StatelessWidget {
  final GameController _gameController = Get.find();
  final UserController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _gamePhase = _gameController.game.value.phase;
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Seek phase 2:39'),
          actions: [
            IconButton(
              onPressed: () async {
                if (_userController.user.value.isAdmin) {
                  Get.defaultDialog(
                      title: 'if you leave, the game will be reset',
                      textConfirm: 'leave game',
                      middleText: '',
                      onConfirm: () async {
                        await Database().reset();
                        _userController.userId.value = '';
                      });
                } else {
                  Get.defaultDialog(
                      title: 'Are you sure you want to leave?',
                      textConfirm: 'leave game',
                      middleText: '',
                      onConfirm: () async {
                        _userController.userId.value = '';
                      });
                }
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: Text('pick up item'),
        ),
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                child: OutlinedButton.icon(
                  style: ButtonStyle(),
                  onPressed: () {
                    if (_gamePhase == playingPhase.counting) {
                      // if (_userController.user.value.isTagger) {

                      // }
                    } else if (_gamePhase == playingPhase.seek) {
                      Get.defaultDialog(
                        title: 'Seek phase:',
                        middleText:
                            'Find an item before the time runs out or the tagger will have your location during the next hide phase!',
                      );
                    } else if (_gamePhase == playingPhase.hide) {
                      Get.defaultDialog(
                        title: 'Hide phase:',
                        middleText:
                            'Your location is "safe" for now. Find another immunity item next seek phase to keep it safe again!',
                      );
                    }
                  },
                  icon: Icon(Icons.help),
                  label: Text('Your location isnt safe'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
