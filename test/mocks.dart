import 'package:geolocator/geolocator.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cysm/controllers/game_controller.dart';
import 'package:cysm/controllers/location_controller.dart';
import 'package:cysm/controllers/user_controller.dart';
import 'package:cysm/models/game.dart';
import 'package:cysm/models/player.dart';
import 'package:cysm/models/safety_item.dart';
import 'package:cysm/services/database.dart';

Player mockTagger = Player('tagger_123', 'test_tagger', false, true, false,
    false, Position.fromMap({'latitude': 1.0, 'longitude': 0.0}));
Player mockHider = Player('hider_678', 'test_hider', false, false, false, false,
    Position.fromMap({'latitude': 1.0, 'longitude': 0.0}));
List<SafetyItem> mockFoundSafetyItems =
    [SafetyItem.fromDefault(), SafetyItem.fromDefault()].obs;
List<Player> mockfoundHiders = [mockHider, mockHider].obs;

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
  final game = Game("id", DateTime.now(), gamePhase.playing,
          GeneratingItems(false, DateTime.now()))
      .obs;
  final players = [mockHider, mockHider].obs;
  final items = List<SafetyItem>.empty().obs;
  var taggingPlayer = false.obs;
  var pickingUpItem = false.obs;

  // @override
  // Future pickUpItem() {
  //   return Future.delayed(Duration(milliseconds: 0));
  // }
}
