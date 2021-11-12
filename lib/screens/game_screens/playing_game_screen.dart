import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/screens/game_screens/compass.dart';
import 'package:niira2/services/database.dart';

class PlayingGameScreen extends StatefulWidget {
  @override
  State<PlayingGameScreen> createState() => _PlayingGameScreenState();
}

class _PlayingGameScreenState extends State<PlayingGameScreen> {
  final GameController _gameController = Get.find();
  final UserController _userController = Get.find();
  final LocationController _locationController = Get.find();
  final Database _database = Get.find();

  bool showTaggerIsComingDialog = true;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _gamePhase = _gameController.game.value.phase;
      final _isTagger = _userController.user.value.isTagger;

      if (showTaggerIsComingDialog &&
          _gamePhase == gamePhase.playing &&
          !_isTagger) {
        WidgetsBinding.instance!.addPostFrameCallback(
          (_) => Get.defaultDialog(
            title: 'Tagger coming!',
            middleText: 'Find safety items to keep your location safe!',
            textConfirm: 'Ok',
            onConfirm: () async {
              setState(() {
                showTaggerIsComingDialog = false;
              });
              Get.back();
            },
          ),
        );
      }

      if (showTaggerIsComingDialog &&
          _gamePhase == gamePhase.counting &&
          !_isTagger) {
        WidgetsBinding.instance!.addPostFrameCallback(
          (_) => Get.defaultDialog(
            title: 'Go hide!',
            middleText:
                'Tagger will be coming soon! find a hiding spot and wait for the safety items to spawn!',
            textConfirm: 'Ok',
            onConfirm: () async {
              setState(() {
                showTaggerIsComingDialog = false;
              });
              Get.back();
            },
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(_userController.user.value.username),
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
                      '''Its hide and seek! Only the tagger has your location... Find safety items around the map to hide your location from the tagger for 90 seconds! Keep finding them, and you could keep your location safe for the whole game. Hide from the tagger and be the last one found to win! ''',
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
                        await _database.reset();
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
        floatingActionButton: _isTagger
            ? _gamePhase == gamePhase.counting
                ? FloatingActionButton.extended(
                    onPressed: () {
                      Get.defaultDialog(
                          title: 'Did you count to 50?',
                          textConfirm: 'Yes, start game',
                          middleText: '',
                          textCancel: 'No',
                          onConfirm: () async {
                            Get.back();
                            await _database.taggerStartGame();
                          });
                    },
                    label: Text('Start game'),
                  )
                : FloatingActionButton.extended(
                    onPressed: () {},
                    label: Text('Tag player'),
                  )
            : FloatingActionButton.extended(
                onPressed: () {},
                label: Text('Pick up item'),
              ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (_gamePhase == gamePhase.counting)
                  _isTagger
                      ? OutlinedButton(
                          child: Text(
                            'Count to 50 then tap start game',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ButtonStyle(),
                          onPressed: () {},
                        )
                      : OutlinedButton(
                          child: Text(
                            'Go hide!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ButtonStyle(),
                          onPressed: () {},
                        ),
                if (!_isTagger && _gamePhase != gamePhase.counting)
                  _userController.user.value.hasImmunity
                      ? OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.check),
                          label: Text('Location safe for 90s'),
                        )
                      : OutlinedButton.icon(
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
                        ),
                OutlinedButton(
                  child: Text(
                    '${_gameController.players.length} players left',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ButtonStyle(),
                  onPressed: () {},
                ),
                _gameController.items.any((item) {
                  final _playerLocation = _locationController.location;

                  final int _distance = Geolocator.distanceBetween(
                    _playerLocation.value.latitude,
                    _playerLocation.value.longitude,
                    item.latitude,
                    item.longitude,
                  ).floor();

                  if (_distance <= 10.5) {
                    return true;
                  } else {
                    return false;
                  }
                })
                    ? FoundSafetyItem()
                    : Compass(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
