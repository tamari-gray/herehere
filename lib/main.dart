import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/screens/game_screens/game_screen.dart';
import 'package:niira2/screens/splash.dart';
import 'package:niira2/services/database.dart';
// import ;ackage:flutter/services.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
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
  final GameController _gameController = Get.put(GameController());
  // ignore: unused_field
  final LocationController _locationController = Get.put(LocationController());

  @override
  // void initState() {
  //   super.initState();
  //   print('hi');
  //   IO.Socket socket = IO.io('http://localhost:8000');
  //   socket.on('connect', (_) {
  //     print('connect');
  //     socket.emit('msg', 'test');
  //   });
  //   socket.on('event', (data) => print(data));
  //   socket.on('disconnect', (_) => print('disconnect'));
  //   socket.on('fromServer', (_) => print(_));
  // }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
