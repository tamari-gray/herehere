import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/services/database.dart';

class Lobby extends StatelessWidget {
  final UserController _userController = Get.find();
  final GameController _gameController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: _userController.user.value.isAdmin
              ? Text('Select tagger')
              : Text('lobby'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await Database().leaveGame(_userController.userId.value);
                _userController.userId.value = '';
              },
              child: Text('leave game'),
            ),
            _userController.user.value.isAdmin
                ? ElevatedButton(
                    onPressed: () async {
                      await Database().reset();
                      _userController.userId.value = '';
                    },
                    child: Text('reset'),
                  )
                : Container(),
          ],
        ),
        body: Container(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: _gameController.players.length,
              itemBuilder: (_, index) {
                final player = _gameController.players[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            player.username,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _userController.user.value.isAdmin
                            ? Checkbox(
                                value: player.isTagger,
                                onChanged: (newValue) {
                                  Database()
                                      .chooseTagger(player.id, player.isTagger);
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
