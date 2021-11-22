import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/models/game.dart';

class SplashPage extends StatelessWidget {
  final LocationController _locationController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          reverse: true,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SplashTitle(),
                  SplashSubtitle(),
                  _locationController.serviceEnabled.value &&
                          (_locationController.locationPermission.value ==
                                  LocationPermission.always ||
                              _locationController.locationPermission.value ==
                                  LocationPermission.whileInUse)
                      ? LogIn()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
                          child: LocationSettingsHandler(),
                        ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class LocationSettingsHandler extends StatefulWidget {
  @override
  State<LocationSettingsHandler> createState() =>
      _LocationSettingsHandlerState();
}

class _LocationSettingsHandlerState extends State<LocationSettingsHandler> {
  final LocationController _locationController = Get.find();

  @override
  void initState() {
    super.initState();
    _checkLocationSettings();
  }

  void _checkLocationSettings() async {
    _locationController.serviceEnabled.value =
        await Geolocator.isLocationServiceEnabled();
    _locationController.locationPermission.value =
        await Geolocator.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (_locationController.serviceEnabled.value) {
          if (_locationController.locationPermission.value ==
                  LocationPermission.always ||
              _locationController.locationPermission.value ==
                  LocationPermission.whileInUse) {
            return Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    title: Text('Please allow location permissions'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        child: const Text('Refresh'),
                        onPressed: () async {
                          await Geolocator.checkPermission();
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text('Allow'),
                        onPressed: () async {
                          _locationController.locationPermission.value =
                              await Geolocator.requestPermission();
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    title: Text('Please enable location services'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        child: const Text('Refresh'),
                        onPressed: () async {
                          _locationController.serviceEnabled.value =
                              await Geolocator.isLocationServiceEnabled();
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text('Enable'),
                        onPressed: () async {
                          await Geolocator.openLocationSettings();
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            );
          }
        }
        return Container(
          child: LoadingIndicator(
            indicatorType: Indicator.ballScaleMultiple,
            colors: const [Colors.white],
            strokeWidth: 2,
            backgroundColor: Colors.black,
            pathBackgroundColor: Colors.black,
          ),
        );
      },
    );
  }
}

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final usernameController = TextEditingController();
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
      () => _gameController.game.value.phase != gamePhase.creating
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
                        if (_username != '') {
                          _username == 'reset game now'
                              ? await _gameController.resetGame()
                              : await _gameController.joinGame(_username);
                        }
                      },
                      child: Text(
                        'Play',
                        style: TextStyle(
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
        'Niira',
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
