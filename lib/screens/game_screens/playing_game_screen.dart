import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/models/safety_item.dart';
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
  bool pickingUpItem = false;
  SafetyItem foundItem = SafetyItem.fromDefault();

  bool taggingPlayer = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _gamePhase = _gameController.game.value.phase;
      final _isTagger = _userController.user.value.isTagger;

      // put live location in firestore if hider
      if (_gamePhase == gamePhase.playing && !_isTagger) {
        final _userId = _userController.userId.value;
        _locationController.updateLocationInDb(_userId);
      }

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
                    onPressed: () async {
                      setState(() {
                        taggingPlayer = true;
                      });
                      final _hider = getTaggedPlayer();
                      await _database.tagHider(_hider.id);
                      setState(() {
                        taggingPlayer = false;
                      });
                      Get.defaultDialog(
                        title: 'Tagged ${_hider.username}!',
                        textConfirm: 'Ok',
                        onConfirm: () => Get.back(),
                        middleText:
                            '${_gameController.players.length} players left',
                      );
                    },
                    label: Text('Tag player'),
                  )
            : FloatingActionButton.extended(
                onPressed: () async {
                  setState(() {
                    pickingUpItem = true;
                  });
                  final item = getFoundSafetyItem();
                  final playerId = _userController.user.value.id;
                  await _database.pickUpItem(item, playerId);
                  setState(() {
                    pickingUpItem = false;
                  });
                  Get.defaultDialog(
                    title: 'Item picked up!',
                    textConfirm: 'Ok',
                    onConfirm: () => Get.back(),
                    middleText:
                        'Your location will be hidden from the tagger for 90 seconds',
                  );
                },
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
                if (!_isTagger && _gamePhase == gamePhase.playing)
                  _userController.locationHiddenTimer.value > 1
                      ? LocationHiddenBanner(userController: _userController)
                      : LocationNotSafeBanner(),
                PlayersRemaining(gameController: _gameController),
                _isTagger
                    ? taggingPlayer
                        ? TaggingPlayer()
                        : checkIfFoundPlayer()
                    : pickingUpItem
                        ? PickingUpItem()
                        : checkIfFoundItem()
                            ? FoundSafetyItem()
                            : Compass(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Player getTaggedPlayer() {
    return _gameController.players.firstWhere((_player) {
      final _playerLocation = _locationController.location;

      final int _distance = Geolocator.distanceBetween(
        _playerLocation.value.latitude,
        _playerLocation.value.longitude,
        _player.location.latitude,
        _player.location.longitude,
      ).floor();

      if (_distance <= 10.5) {
        return true;
      } else {
        return false;
      }
    });
  }

  Widget checkIfFoundPlayer() {
    final Player foundPlayer = _gameController.players.firstWhere((_player) {
      final _playerLocation = _locationController.location;

      final int _distance = Geolocator.distanceBetween(
        _playerLocation.value.latitude,
        _playerLocation.value.longitude,
        _player.location.latitude,
        _player.location.longitude,
      ).floor();

      if (_distance <= 10.5) {
        return true;
      } else {
        return false;
      }
    }, orElse: () => Player.fromDefault());
    if (foundPlayer.username == "") {
      return Compass();
    } else {
      return FoundPlayer(player: foundPlayer);
    }
  }

  SafetyItem getFoundSafetyItem() {
    return _gameController.items.firstWhere((item) {
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
    });
  }

  bool checkIfFoundItem() {
    return _gameController.items.any((item) {
      final _playerLocation = _locationController.location;
      print(_playerLocation);

      final int _distance = Geolocator.distanceBetween(
        _playerLocation.value.latitude,
        _playerLocation.value.longitude,
        item.latitude,
        item.longitude,
      ).floor();

      if (_distance <= 10.5) {
        print(item.pickedUp);
        return true;
      } else {
        return false;
      }
    });
  }
}

class LocationHiddenBanner extends StatelessWidget {
  const LocationHiddenBanner({
    Key? key,
    required UserController userController,
  })  : _userController = userController,
        super(key: key);

  final UserController _userController;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(Icons.check),
      label: Text(
          'Location safe for ${_userController.locationHiddenTimer.value}s'),
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
      child: Text(
        '${_gameController.players.length} players left',
        style: TextStyle(fontWeight: FontWeight.bold),
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
