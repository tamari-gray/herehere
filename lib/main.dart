import 'package:flutter/material.dart';
import 'package:niira2/route_generator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niira 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      home: SplashPage(),
    );
  }
}

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
                padding: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // minimumSize: Size(50, 50),
                          primary: Color.fromRGBO(247, 152, 0, 1),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed('/lobby', arguments: false);
                        },
                        child: Text(
                          'Play game',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.all(5),
                          child: Text('or',
                              style: TextStyle(color: Colors.white))),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            // minimumSize: Size(50, 20),
                            primary: Color.fromRGBO(247, 152, 0, 1),
                            textStyle: TextStyle(
                              color: Color.fromRGBO(247, 152, 0, 1),
                            )),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/admin');
                        },
                        child: Text(
                          'Admin',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
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

class AdminSignIn extends StatefulWidget {
  AdminSignIn({Key? key}) : super(key: key);

  @override
  _AdminSignInState createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Center(
          child: TextField(
            controller: myController,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        if (myController.text == 'i eat poo') {
          Navigator.of(context).pushNamed('/lobby', arguments: true);
        }
      }),
    );
  }
}

class Lobby extends StatefulWidget {
  final bool isAdmin;
  Lobby(this.isAdmin);

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  double _seekPhase = 2.5;
  double _hidePhase = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            Text(
              'Seek phase time',
              style: TextStyle(fontSize: 18),
            ),
            widget.isAdmin
                ? Slider(
                    max: 5,
                    value: this._seekPhase,
                    label: '$_seekPhase minutes',
                    divisions: 10,
                    onChanged: (double val) => setState(() {
                          _seekPhase = val;
                        }))
                : Container(),
            Text(
              'Hide phase time',
              style: TextStyle(fontSize: 18),
            ),
            widget.isAdmin
                ? Slider(
                    max: 10,
                    value: this._hidePhase,
                    label: '$_hidePhase minutes',
                    divisions: 10,
                    onChanged: (double val) => setState(() {
                          _hidePhase = val;
                        }))
                : Container(),
          ],
        ),
      ),
    );
  }
}
