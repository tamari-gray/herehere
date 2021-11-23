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
  var taggingPlayer = false.obs;
  var pickingUpItem = false.obs;
  var joiningGame = false.obs;

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

  int allHiders() => players.where((p) => !p.isTagger).length;

  Future<void> joinGame(String _username) async {
    joiningGame = true.obs;
    final GeoPoint _locationAsGeopoint =
        await _locationController.getLocationAsGeopoint();
    if (_username == 'kawaiifreak97') {
      await _userController.joinGame(_username, true, _locationAsGeopoint);
    } else {
      await _userController.joinGame(_username, false, _locationAsGeopoint);
    }
    joiningGame = false.obs;
  }

  List<Player> getFoundHiders() => players
      .where((_player) => !_player.isTagger)
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

  Future<dynamic> tagPlayer() async {
    taggingPlayer = true.obs;
    final _hiders = getFoundHiders();
    if (_hiders.isEmpty) {
      taggingPlayer = false.obs;
      return noPlayersFoundDialog();
    } else {
      await _database.tagHiders(_hiders);
      taggingPlayer = false.obs;
      justTaggedHidersDialog(_hiders);
    }
  }

  Future<dynamic> pickUpItem() async {
    pickingUpItem = true.obs;
    final _userId = _userController.userId.value;
    final _items = getFoundSafetyItems();
    if (_items.isEmpty) {
      pickingUpItem = false.obs;
      return noItemsFoundDialog();
    } else {
      await _database.pickUpItems(_items, _userId);
      pickingUpItem = false.obs;
      itemsPickedUpDialog(_items.length);
    }
  }

  Future<void> resetGame() async {
    _userController.resetUser();
    await _database.reset();
  }

  // Dialogs

  Future<dynamic> noPlayersFoundDialog() {
    return Get.defaultDialog(
      title: 'No players found',
      textConfirm: 'Ok',
      onConfirm: () => Get.back(),
      middleText: 'keep trying!',
    );
  }

  Future<dynamic> justTaggedHidersDialog(List<Player> _hiders) {
    final _hidersUsernames = _hiders.map((e) => e.username).join(",");
    return Get.defaultDialog(
      title: _hiders.length > 1
          ? 'Tagged $_hidersUsernames!'
          : 'Tagged ${_hiders.map((e) => e.username).join(",")}!',
      textConfirm: 'Ok',
      onConfirm: () => Get.back(),
      middleText: '${players.length} players left',
    );
  }

  void noItemsFoundDialog() {
    Get.defaultDialog(
      title: 'No items found ',
      textConfirm: 'Ok',
      onConfirm: () => Get.back(),
      middleText: 'Keep looking!',
    );
  }

  void itemsPickedUpDialog(int _items) {
    Get.defaultDialog(
      title: '${_items == 1 ? 'Item' : '$_items Items'} picked up!',
      textConfirm: 'Ok',
      onConfirm: () => Get.back(),
      middleText:
          'Your location will be hidden from the tagger for 90 ${_userController.locationHiddenTimer.value < 0 ? 'more ' : ''} seconds',
    );
  }
}
