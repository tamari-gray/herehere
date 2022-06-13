import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cysm/controllers/location_controller.dart';
import 'package:cysm/controllers/user_controller.dart';
import 'package:cysm/models/game.dart';
import 'package:cysm/models/player.dart';
import 'package:cysm/models/safety_item.dart';
import 'package:cysm/services/database.dart';

class GameController extends GetxController {
  final Database _database = Get.find();
  final UserController _userController = Get.find();
  final LocationController _locationController = Get.find();

  final game = Game.fromDefault().obs;

  final players = List<Player>.empty().obs;
  final items = List<SafetyItem>.empty().obs;

  var foundHiders = List<Player>.empty().obs;
  var foundItems = List<SafetyItem>.empty().obs;

  var taggingPlayer = false.obs;
  var pickingUpItem = false.obs;

  Timer _itemRespawnTimer = Timer(Duration(seconds: 0), () => 0);
  var itemRespawnTime = 30.obs;
  var itemRespawnTimerIsGoing = false.obs;

  @override
  void onInit() {
    super.onInit();
    game.bindStream(_database.gameStream());
    players.bindStream(_database.playersStream());
    items.bindStream(_database.availableSafetyItemStream());
  }

  void stopItemRespawnTimer() {
    if (_itemRespawnTimer.isActive) _itemRespawnTimer.cancel();
    itemRespawnTimerIsGoing = false.obs;
    itemRespawnTime = 30.obs;
  }

  void startItemRespawnTimer() {
    itemRespawnTimerIsGoing = true.obs;
    itemRespawnTime = 30.obs;

    _itemRespawnTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (itemRespawnTime.value >= 1) {
        itemRespawnTime.value--;
      }
      if (itemRespawnTime.value <= 0) {
        stopItemRespawnTimer();
      }
    });
  }

  int timeToTagAllHiders() =>
      DateTime.now().difference(game.value.startTime).inMinutes;

  List<Player> hidersRemaining() =>
      players.where((p) => !p.hasBeenTagged && !p.isTagger).toList();

  int allHiders() => players.where((p) => !p.isTagger).length;

  List<Hider> hidersWithAngleAndDistance(
      Position _userLocation, double _userBearing, List<Player> _hiders) {
    return _hiders.map((_hider) {
      final _angle =
          _locationController.angleFromUser(_userLocation, _hider.location);
      final _distance =
          _locationController.distanceFromUser(_userLocation, _hider.location);
      return Hider(
        _hider.id,
        _hider.username,
        _hider.isAdmin,
        _hider.isTagger,
        _hider.hasBeenTagged,
        _hider.locationHidden,
        _hider.location,
        _angle,
        _distance,
      );
    }).toList();
  }

  List<SafetyItem> itemsWithAngleAndDistance(
      Position _userLocation, double _userBearing, List<SafetyItem> _items) {
    return _items.map((_item) {
      final _angle =
          _locationController.angleFromUser(_userLocation, _item.location);
      final _distance =
          _locationController.distanceFromUser(_userLocation, _item.location);
      final _newItem = SafetyItem(
        _item.id,
        _item.location,
      );
      _newItem.angleFromUser = _angle;
      _newItem.distance = _distance;
      return _newItem;
    }).toList();
  }

  Future<void> joinGame(String _username, GeoPoint _locationAsGeopoint) async {
    if (_username != '') {

      if (_username == 'reset game now') {
        await resetGame();
      } else {
        if (_username == 'kawaiifreak97') {
          await _userController.joinGame(_username, true, _locationAsGeopoint);
        } else if (_username == 'kawaiiplusone') {
          await _userController.joinGamePlusOne(
              'kawaiifreak97', true, _locationAsGeopoint);
        } else if (_username == 'kiwi-admin') {
          await _userController.joinGame(_username, true, _locationAsGeopoint);
        } else {
          await _userController.joinGame(_username, false, _locationAsGeopoint);
        }
      }
    }
  }

  Future<dynamic> tagPlayers() async {
    taggingPlayer = true.obs;
    if (foundHiders.isEmpty) {
      taggingPlayer = false.obs;
      return noPlayersFoundDialog();
    } else {
      await _database.tagHiders(foundHiders);
      taggingPlayer = false.obs;
      if (hidersRemaining().length != foundHiders.length)
        justTaggedHidersDialog(foundHiders);
    }
  }

  Future<dynamic> pickUpItems() async {
    pickingUpItem = true.obs;
    final _userId = _userController.userId.value;

    if (foundItems.isEmpty) {
      pickingUpItem = false.obs;
      return noItemsFoundDialog();
    } else {
      final amountOfPickedUpItems =
          await _database.pickUpItems(foundItems, _userId);
      pickingUpItem = false.obs;
      itemsPickedUpDialog(amountOfPickedUpItems);
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
      middleText: '${hidersRemaining().length - 1} players left',
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
