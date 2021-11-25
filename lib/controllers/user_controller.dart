import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/services/database.dart';

class UserController extends GetxController {
  final Database _database = Get.find();

  var userId = ''.obs;
  final user = Player.fromDefault().obs;
  var locationHiddenTimer = 0.obs;
  final pickedUpItemsTimes = <DateTime>[].obs;

  Timer _timer = Timer(Duration(seconds: 0), () => 0);

  void logIn(String id) {
    if (id != '') {
      user.bindStream(_database.userDocStream(id));
      pickedUpItemsTimes.bindStream(_database.pickedUpItemsStream(id));
    }
  }

  Future<void> joinGame(
      String _username, bool isAdmin, GeoPoint _location) async {
    userId.value = await _database.joinGame(_username, true, _location);
  }

  Future<void> joinGamePlusOne(
      String _username, bool isAdmin, GeoPoint _location) async {
    await _database.joinGame('yeet it', false, _location);
    userId.value = await _database.joinGame(_username, true, _location);
  }

  void calcLocationSafetyTime() async {
    if (_timer.isActive) _timer.cancel();

    var _timerTime = 0;

    pickedUpItemsTimes.forEach((itemTime) {
      final _difference = DateTime.now().difference(itemTime).inSeconds;

      if (_difference <= 90) {
        final _newTime = 90 - _difference;
        _timerTime = _timerTime + _newTime;
      }
    });

    locationHiddenTimer.value = _timerTime;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (locationHiddenTimer.value == 0) {
        await _database.hiderItemsExpire(userId.value);
        _timer.cancel();
      } else {
        locationHiddenTimer.value = locationHiddenTimer.value - 1;
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    ever(userId, (_) => logIn(userId.value));
    ever(pickedUpItemsTimes, (_) => calcLocationSafetyTime());
  }

  void resetUser() => userId.value = "";

  Future<void> leaveGame() async {
    final _userId = userId.value;
    resetUser();
    await _database.leaveGame(_userId);
  }
}
