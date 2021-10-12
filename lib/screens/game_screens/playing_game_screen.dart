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
          title: Text(''),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.defaultDialog(
                    titleStyle: TextStyle(fontSize: 28),
                    titlePadding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    title: 'How to play Niira2',
                    textConfirm: 'Bring it on frank',
                    contentPadding: EdgeInsets.all(15),
                    content: Text(
                      '''Its hide and seek! Only the tagger(s) have your location... Find safety items around the map that will keep your location safe for 90 seconds! If you keep finding safety items, its possible to keep your location safe the whole game . Hide from the tagger(s) and be the last one found to win! ''',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    onConfirm: () async {
                      Get.back();
                    });
              },
              child: Text('How to play'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Container(),
            ),
            IconButton(
              onPressed: () async {
                if (_userController.user.value.isAdmin) {
                  Get.defaultDialog(
                      title: 'if you leave, the game will be reset',
                      textConfirm: 'leave game',
                      middleText: '',
                      onConfirm: () async {
                        Get.back();
                        await Database().reset();
                        _userController.userId.value = '';
                      });
                } else {
                  Get.defaultDialog(
                      title: 'Are you sure you want to leave?',
                      textConfirm: 'leave game',
                      middleText: '',
                      onConfirm: () async {
                        Get.back();
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
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
              //   child: OutlinedButton.icon(
              //     style: ButtonStyle(),
              //     onPressed: () {
              //       if (_gamePhase == playingPhase.counting) {
              //         // if (_userController.user.value.isTagger) {

              //         // }
              //       } else if (_gamePhase == playingPhase.seek) {
              //         Get.defaultDialog(
              //           title: 'Seek phase:',
              //           middleText:
              //               'Find an item before the time runs out or the tagger will have your location during the next hide phase!',
              //         );
              //       } else if (_gamePhase == playingPhase.hide) {
              //         Get.defaultDialog(
              //           title: 'Hide phase:',
              //           middleText:
              //               'If you didnt find an item, the tagger has your location until the end of the hide phase!',
              //         );
              //       }
              //     },
              //     icon: Icon(Icons.help),
              //     label: Text('Your location isnt safe'),
              //   ),
              // ),
            ],
          ),
        ),
      );
    });
  }
}
