import 'package:async_button_builder/async_button_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:cysm/controllers/game_controller.dart';
import 'package:cysm/controllers/location_controller.dart';
import 'package:cysm/models/game.dart';
import 'dart:io' show Platform;
import 'package:rounded_loading_button/rounded_loading_button.dart';

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
                          (_locationController.locationAccuracy.value ==
                                  LocationAccuracyStatus.precise &&
                              Platform.isIOS) &&
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
    await _locationController.checkLocationSettings();
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
            if (_locationController.locationAccuracy.value !=
                    LocationAccuracyStatus.precise &&
                Platform.isIOS) {
              return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      title: Text('Please enable precise location'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('Refresh'),
                          onPressed: () async {
                            _checkLocationSettings();
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          child: const Text('Enable'),
                          onPressed: () async {
                            Geolocator.openLocationSettings();
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              );
            }
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
  final LocationController _locationController = Get.find();
  GeoPoint _location = GeoPoint(0, 0);

  final RoundedLoadingButtonController _loginBtnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the text controller when the widget is disposed.
    usernameController.dispose();
    super.dispose();
  }

  getLocation() async {
    final GeoPoint _locationAsGeopoint =
        await _locationController.getLocationAsGeopoint();
    setState(() {
      _location = _locationAsGeopoint;
    });
  }

  void _login(String _username) async {
    if (_username != '') {
      _username == 'reset game now'
          ? await _gameController.resetGame()
          : await _gameController.joinGame(
              _username,
              _location,
            );
      _loginBtnController.success();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _gameController.game.value.phase != gamePhase.creating
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
          : _location == GeoPoint(0, 0)
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                  child: Container(
                    child: Center(
                      child: Text(
                        'Please wait while we get your location...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(50, 75, 50, 0),
                  child: Container(
                      child: Column(
                    children: [
                      Row(
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
                          AsyncButtonBuilder(
                            showError: false,
                            showSuccess: false,
                            loadingWidget: Text('Joining game...'),
                            child: Text(
                              'Join game',
                              style: TextStyle(
                                color: const Color(0xff82fab8),
                              ),
                            ),
                            onPressed: () async {
                              final _username = usernameController.text;
                              if (_username != '') {
                                _username == 'reset game now'
                                    ? await _gameController.resetGame()
                                    : await _gameController.joinGame(
                                        _username,
                                        _location,
                                      );
                              }

                              throw 'yikes, problem logging in.';
                            },
                            builder: (context, child, callback, buttonState) {
                              return OutlinedButton(
                                onPressed: callback,
                                child: child,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  )),
                );
    });
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
            text: 'Super ',
          ),
          TextSpan(
            text: 'spotlight',
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
        'CYSM',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 64,
          color: const Color(0xffface4d),
          letterSpacing: 4,
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

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
