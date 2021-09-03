import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/screens/game_screen.dart';
import 'package:niira2/screens/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: App()));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print('error initializing firebase');
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Container(
                child: Text('initializing firebase'),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  final UserController _userController = Get.put(UserController());
  final GameController _gameController = Get.put(GameController());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niira 2',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: Obx(
        () => _userController.userId.value.isNotEmpty
            ? JoinedGame()
            : SplashPage(),
      ),
    );
  }
}
