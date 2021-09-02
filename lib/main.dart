import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:niira2/controllers/player_controller.dart';
import 'package:niira2/screens/lobby.dart';
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
        return Text('initializing firebase');
      },
    );
  }
}

class MyApp extends StatelessWidget {
  final PlayerController _playerController = Get.put(PlayerController());
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niira 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Obx(
        () => _playerController.hasLoggedIn.value ? Lobby() : SplashPage(),
      ),
    );
  }
}
