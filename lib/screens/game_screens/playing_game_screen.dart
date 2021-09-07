import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/user_controller.dart';

class PlayingGameScreen extends StatelessWidget {
  final GameController _gameController = Get.find();
  final UserController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2:39'),
        actions: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.help, textDirection: TextDirection.ltr),
              label: Text('Seek phase'),
            ),
          ),
          _userController.user.value.isAdmin
              ? IconButton(
                  onPressed: () async {
                    // await Database().reset();
                    // _userController.userId.value = '';
                  },
                  icon: Icon(Icons.more_vert),
                )
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // _gameController.phase.value = gamePhase.initialising;
        },
        label: Text('tag player'),
      ),
      body: Container(
        child: Center(
          child: Text('playing game'),
        ),
      ),
    );
  }
}
