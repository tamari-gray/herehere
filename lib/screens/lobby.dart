import 'package:cysm/controllers/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cysm/controllers/game_controller.dart';
import 'package:cysm/controllers/user_controller.dart';
import 'package:cysm/services/database.dart';

class Lobby extends StatelessWidget {
  final UserController _userController = Get.find();
  final GameController _gameController = Get.find();
  final LocationController _locationController = Get.find();
  final Database _database = Get.find();

  _leaveGame(String _userId) async {
    await _userController.leaveGame();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isAdmin = _userController.user.value.isAdmin;
      final _userId = _userController.userId.value;

      return Scaffold(
        appBar: AppBar(
          title: isAdmin ? Text('Select tagger') : Text('lobby'),
          actions: [
            ElevatedButton(
              onPressed: () => _leaveGame(_userId),
              child: Text('leave game'),
            ),
            isAdmin
                ? ElevatedButton(
                    onPressed: () async {
                      await _gameController.resetGame();
                    },
                    child: Text('reset'),
                  )
                : Container(),
          ],
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: () async {
                  if (_gameController.players
                      .any((player) => player.isTagger)) {
                    await _database.playGame();
                  }
                },
                label: _gameController.players.any((player) => player.isTagger)
                    ? Text('Start game')
                    : Text('Select Tagger to start game'),
              )
            : Container(),
        // checks if game gets reset while playing
        body: _gameController.players.length == 0
            ? Container(
                child: Center(
                  child: Text(
                    'Please leave game and rejoin',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              )
            : Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _gameController.players.length,
                    itemBuilder: (_, index) {
                      final player = _gameController.players[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${player.username}: ${player.locationAccuracy}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              isAdmin
                                  ? Checkbox(
                                      value: player.isTagger,
                                      onChanged: (newValue) {
                                        _database.chooseTagger(
                                            player.id, player.isTagger);
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
      );
    });
  }
}
