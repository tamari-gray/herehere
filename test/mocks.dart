import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/models/safety_item.dart';
import 'package:niira2/services/database.dart';

class MockDatabase extends GetxService with Mock implements Database {}

class MockUserController extends GetxController
    with Mock
    implements UserController {
  final userId = 'tam'.obs;
  final user = Player(
    "tam",
    "kawaiifreak97",
    true,
    false,
    false,
    false,
    Position.fromMap({'latitude': 1.0, 'longitude': 0.0}),
  ).obs;
  final safetyItemTime = 90.obs;
  var locationHiddenTimer = 0.obs;
}

class MockLocationController extends GetxController
    with Mock
    implements LocationController {
  final location = Position.fromMap({'latitude': 1.0, 'longitude': 0.0}).obs;
  var serviceEnabled = false.obs;
  var locationPermission = LocationPermission.denied.obs;
}

class MockGameController extends GetxController
    with Mock
    implements GameController {
  final game = Game("id", DateTime.now(), gamePhase.playing).obs;
  final players = List<Player>.empty().obs;
  final items = List<SafetyItem>.empty().obs;
}
