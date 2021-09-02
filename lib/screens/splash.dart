import 'package:flutter/material.dart';
import 'package:niira2/services/database.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final usernameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
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
              ),
              Text.rich(
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
              ),
              Padding(
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
                        onPressed: () {
                          if (usernameController.text != '') {
                            if (usernameController.text == 'pooeater') {
                              // sign in as admin

                            } else {
                              // sign up as player
                              Database().joinGame(usernameController.text);
                            }
                          }
                        },
                        child: Text(
                          'Play',
                          style:
                              TextStyle(color: Color.fromRGBO(247, 152, 0, 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
