import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/services/database.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SplashTitle(),
              SplashSubtitle(),
              LogIn(),
            ],
          ),
        ),
      ),
    );
  }
}

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final usernameController = TextEditingController();
  final UserController _userController = Get.find();
  final GameController _gameController = Get.find();

  @override
  void dispose() {
    // Clean up the text controller when the widget is disposed.
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _gameController.game.value.stage != niiraStage.initialising
          ? Padding(
              padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
              child: Container(
                child: Center(
                  child: Text(
                    'Game being played, please wait.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(50, 75, 50, 0),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        cursorColor: const Color(0xff82fab8),
                        style: TextStyle(color: Colors.white),
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Enter username',
                          labelStyle: TextStyle(
                            color: const Color(0xff82fab8),
                          ),
                          border: InputBorder.none,
                        ),
                        controller: usernameController,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final _username = usernameController.text;
                        String _userId;
                        if (_username != '') {
                          if (_username == 'kawaiifreak97ftp') {
                            _userId =
                                await Database().joinGame(_username, true);
                          } else {
                            _userId =
                                await Database().joinGame(_username, false);
                          }
                          _userController.userId.value = _userId;
                        }
                      },
                      child: Text(
                        'Play',
                        style: TextStyle(
                          // color: Color.fromRGBO(247, 152, 0, 1),
                          color: const Color(0xff82fab8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class SplashSubtitle extends StatelessWidget {
  const SplashSubtitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: 'Helvetica Neue',
          fontSize: 24,
          color: const Color(0xff82fab8),
        ),
        children: [
          TextSpan(
            text: 'Hyper ',
          ),
          TextSpan(
            text: 'hide and go seek',
            style: TextStyle(
              color: const Color(0xfffefefe),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class SplashTitle extends StatelessWidget {
  const SplashTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 200, 0, 0),
      child: Text(
        'Niira2',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 96,
          color: const Color(0xffface4d),
          letterSpacing: 8.553599853515625,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              color: const Color(0xfff71a0d),
              offset: Offset(0, 3),
              blurRadius: 15,
            )
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
