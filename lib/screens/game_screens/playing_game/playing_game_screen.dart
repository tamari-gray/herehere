import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/safety_item.dart';
import 'package:niira2/screens/game_screens/playing_game/compass_for_hider.dart';
import 'package:niira2/screens/game_screens/playing_game/compass_for_tagger.dart';
import 'package:niira2/screens/game_screens/playing_game/widgets.dart';
import 'package:niira2/services/database.dart';
import 'package:niira2/utilities/placing.dart';

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
  SafetyItem foundItem = SafetyItem.fromDefault();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _userId = _userController.userId.value;
      final _isAdmin = _userController.user.value.isAdmin;

      final _gamePhase = _gameController.game.value.phase;
      final _isTagger = _userController.user.value.isTagger;

      final _taggingPlayer = _gameController.taggingPlayer.value;
      final _pickingUpItem = _gameController.pickingUpItem.value;

      final _userLocation = _locationController.location.value;

      final _hidersRemaining = _gameController.players
          .where((p) => !p.hasBeenTagged && !p.isTagger)
          .toList();

      // put live location in firestore if hider
      if (_gamePhase == gamePhase.playing && !_isTagger) {
        _locationController.updateLocationInDb(_userId);
      }

      if (showTaggerIsComingDialog &&
          _gamePhase == gamePhase.playing &&
          !_isTagger &&
          _userId != '') {
        WidgetsBinding.instance!.addPostFrameCallback(
          (_) => taggerComingDialog(),
        );
      }

      if (showTaggerIsComingDialog &&
          _gamePhase == gamePhase.counting &&
          !_isTagger) {
        WidgetsBinding.instance!.addPostFrameCallback(
          (_) => goHideDialog(),
        );
      }

      if (_userController.user.value.hasBeenTagged) {
        WidgetsBinding.instance!.addPostFrameCallback(
          (_) => hiderFinishedGameDialog(_hidersRemaining.length),
        );
      }

      if (_isTagger && _hidersRemaining.length == 0) {
        WidgetsBinding.instance!.addPostFrameCallback(
          (_) => taggerFinishedGameDialog(),
        );
      }

      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(_userController.user.value.username),
          actions: [
            _isAdmin
                ? ElevatedButton(
                    onPressed: () async => await resetGameDialog(),
                    child: Text('reset'),
                  )
                : ElevatedButton(
                    onPressed: () async => await howToPlayDialog(),
                    child: Text('How to play'),
                  ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Container(),
            ),
            IconButton(
              onPressed: () async =>
                  _isTagger ? await resetGameDialog() : await leaveGameDialog(),
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: _isTagger
            ? _gamePhase == gamePhase.counting
                ? FloatingActionButton.extended(
                    onPressed: () async =>
                        await checkIfTaggerFinishedCountingDialog(),
                    label: Text('Start game'),
                  )
                : FloatingActionButton.extended(
                    onPressed: () async => !_gameController.taggingPlayer.value
                        ? await _gameController.tagPlayers()
                        : null,
                    label: Text('Tag player'),
                  )
            : _gamePhase == gamePhase.counting
                ? Container()
                : FloatingActionButton.extended(
                    onPressed: () async => !_gameController.pickingUpItem.value
                        ? await _gameController.pickUpItems()
                        : null,
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
                      ? LocationHiddenBanner()
                      : LocationNotSafeBanner(),
                HidersRemaining(),
                _isTagger
                    ? _taggingPlayer
                        ? TaggingPlayer()
                        : CompassForTagger()
                    : _pickingUpItem
                        ? PickingUpItem()
                        : CompassForHider()
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<dynamic> checkIfTaggerFinishedCountingDialog() async {
    return Get.defaultDialog(
        title: 'Did you count to 50?',
        textConfirm: 'Yes, start game',
        middleText: '',
        textCancel: 'No',
        onConfirm: () async {
          Get.back();
          await _database.taggerStartGame();
        });
  }

  Future<dynamic> howToPlayDialog() async {
    return Get.defaultDialog(
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
        onConfirm: () {
          Get.back();
        });
  }

  Future<dynamic> taggerFinishedGameDialog() async {
    return Get.defaultDialog(
      title: 'Game finished!',
      middleText:
          'Good job! you tagged ${_gameController.allHiders()} players in ${_gameController.timeToTagAllHiders()} minutes. Thanks for the game :) ',
      textConfirm: 'Continue',
      onConfirm: () async {
        Get.back();
        // await _userController.leaveGame();
        await _gameController.resetGame();
      },
    );
  }

  Future<dynamic> hiderFinishedGameDialog(int playersRemaining) async {
    return Get.defaultDialog(
      title: 'You came ${placing(playersRemaining + 1)}',
      middleText: 'Thanks for the game :)',
      textConfirm: 'Continue',
      onConfirm: () async {
        Get.back();
        await _userController.leaveGame();
      },
    );
  }

  Future<dynamic> goHideDialog() {
    return Get.defaultDialog(
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
    );
  }

  Future<dynamic> taggerComingDialog() {
    return Get.defaultDialog(
      title: 'Tagger coming!',
      middleText: 'Find safety items to keep your location safe!',
      textConfirm: 'Ok',
      onConfirm: () async {
        setState(() {
          showTaggerIsComingDialog = false;
        });
        Get.back();
      },
    );
  }

  Future<dynamic> resetGameDialog() async {
    return Get.defaultDialog(
        title: 'Leaving will reset the game',
        textConfirm: 'leave',
        middleText: 'or tap outside box to cancel',
        onConfirm: () async {
          Get.back();
          await _gameController.resetGame();
        });
  }

  Future<dynamic> leaveGameDialog() async {
    return Get.defaultDialog(
        title: 'Are you sure you want to leave?',
        textConfirm: 'leave game',
        middleText: '',
        onConfirm: () async {
          Get.back();
          await _userController.leaveGame();
        });
  }
}
