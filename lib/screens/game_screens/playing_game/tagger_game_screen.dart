import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herehere/controllers/game_controller.dart';
import 'package:herehere/controllers/user_controller.dart';
import 'package:herehere/models/game.dart';
import 'package:herehere/models/safety_item.dart';
import 'package:herehere/screens/game_screens/playing_game/Compass/compass_for_tagger.dart';
import 'package:herehere/screens/game_screens/playing_game/widgets.dart';
import 'package:herehere/services/database.dart';

class TaggerGameScreen extends StatefulWidget {
  @override
  State<TaggerGameScreen> createState() => _TaggerGameScreenState();
}

class _TaggerGameScreenState extends State<TaggerGameScreen> {
  final GameController _gameController = Get.find();
  final UserController _userController = Get.find();
  final Database _database = Get.find();

  bool showtaggerFinishedGameDialog = true;
  bool showJustTaggedDialog = true;

  String lastTaggedHiders = "";

  SafetyItem foundItem = SafetyItem.fromDefault();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _userId = _userController.userId.value;
      final _isAdmin = _userController.user.value.isAdmin;

      final _gamePhase = _gameController.game.value.phase;

      final _hidersRemaining = _gameController.players
          .where((p) => !p.hasBeenTagged && !p.isTagger)
          .toList();

      if (showtaggerFinishedGameDialog && _hidersRemaining.length == 0) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            setState(() {
              showtaggerFinishedGameDialog = false;
            });
            final _hiders = _gameController.allHiders();
            final _time = _gameController.timeToTagAllHiders();
            await _userController.leaveGame();
            taggerFinishedGameDialog(_hiders, _time);
          },
        );
      }

      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(_userController.user.value.username),
          actions: [
            _isAdmin
                ? ElevatedButton(
                    onPressed: () async => await resetGameDialog(_userId),
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
              onPressed: () async => await resetGameDialog(_userId),
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: _gamePhase == gamePhase.counting
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
              ),
        body: TaggerScreenUI(),
      );
    });
  }

  Future<dynamic> justTaggedDialog(String _justTaggedHiders, int _hidersLeft) {
    return Get.defaultDialog(
        title: '$_justTaggedHiders was tagged!',
        middleText: '$_hidersLeft hiders left',
        textConfirm: 'Cool beans',
        onConfirm: () {
          setState(() {
            showJustTaggedDialog = true;
            lastTaggedHiders = _justTaggedHiders;
          });
          Get.back();
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
        title: 'How to play herehere',
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

  Future<dynamic> taggerFinishedGameDialog(int _hiders, int _time) {
    return Get.defaultDialog(
      title: 'Game finished!',
      middleText:
          'Good job! you tagged $_hiders players in $_time minutes. Thanks for the game :) ',
      textConfirm: 'Continue',
      onConfirm: () => Get.back(),
    );
  }

  Future<dynamic> resetGameDialog(String _userId) async {
    return Get.defaultDialog(
        title: 'Leaving will reset the game',
        textConfirm: 'leave',
        middleText: 'or tap outside box to cancel',
        onConfirm: () async {
          Get.back();
          await _gameController.resetGame();
        });
  }

  Future<dynamic> leaveGameDialog(String _userId) async {
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

class TaggerScreenUI extends StatelessWidget {
  final GameController _gameController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
        child: Obx(
          () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _gameController.game.value.phase == gamePhase.counting
                    ? OutlinedButton(
                        child: Text(
                          'Count to 50 then tap start game',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ButtonStyle(),
                        onPressed: () {},
                      )
                    : Container(),
                HidersRemaining(),
                _gameController.taggingPlayer.value
                    ? TaggingPlayer()
                    : CompassForTagger()
              ]),
        ),
      ),
    );
  }
}
