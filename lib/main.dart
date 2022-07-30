import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:cysm/controllers/game_controller.dart';
import 'package:cysm/controllers/location_controller.dart';
import 'package:cysm/controllers/user_controller.dart';
import 'package:cysm/screens/game_screens/game_screen.dart';
import 'package:cysm/screens/splash.dart';
import 'package:cysm/services/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// all controllers depend on `Database`.We instatiate it here first so
  /// controllers can use it with `GetX`.
  // ignore: unused_field
  final Database _database = Get.put(Database());

  final UserController _userController = Get.put(UserController());
  // ignore: unused_field
  final LocationController _locationController = Get.put(LocationController());
  // ignore: unused_field
  final GameController _gameController = Get.put(GameController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'herehere',
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
