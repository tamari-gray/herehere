import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/models/safety_item.dart';
import 'package:niira2/services/database.dart';

class GameController extends GetxController {
  final Database _database = Get.find();
  final UserController _userController = Get.find();
  final LocationController _locationController = Get.find();

  final game = Game.fromDefault().obs;
  final players = List<Player>.empty().obs;
  final items = List<SafetyItem>.empty().obs;

  @override
  void onInit() {
    super.onInit();
    game.bindStream(_database.gameStream());
    players.bindStream(_database.playersStream());
    items.bindStream(_database.availableSafetyItemStream());
  }

  int timeToTagAllHiders() =>
      DateTime.now().difference(game.value.startTime).inMinutes;

  int playersRemaining() =>
      players.where((p) => !p.hasBeenTagged && !p.isTagger).length;

  Future<void> joinGame(String _username) async {
    final GeoPoint _locationAsGeopoint =
        await _locationController.getLocationAsGeopoint();
    if (_username == 'kawaiifreak97') {
      _userController.joinGame(_username, true, _locationAsGeopoint);
    } else {
      _userController.joinGame(_username, false, _locationAsGeopoint);
    }
  }

  List<Player> getFoundHiders() => players
      .where((_hider) => _locationController.distanceBetween(_hider.location))
      .toList();

  List<SafetyItem> getFoundSafetyItems() => items
      .where((_item) => _locationController.distanceBetween(
            Position.fromMap({
              'latitude': _item.latitude,
              'longitude': _item.longitude,
            }),
          ))
      .toList();

  Future<void> resetGame() async {
    _userController.resetUser();
    await _database.reset();
  }
}
