import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:cysm/models/player.dart';
import 'package:cysm/services/database.dart';

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
    userId.value = await _database.joinGame(_username, isAdmin, _location);
  }

  Future<void> joinGamePlusOne(
      String _username, bool isAdmin, GeoPoint _location) async {
    await _database.joinGame(
        'yeet it', false, GeoPoint(-39.63873726809591, 176.86164435458016));
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
        if (userId.value == "") {
          _timer.cancel();
        } else {
          await _database.hiderItemsExpire(userId.value);
          _timer.cancel();
        }
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

  void resetUser() async {
    userId.value = "";
    if (_timer.isActive) _timer.cancel();
  }

  Future<void> leaveGame() async {
    await _database.leaveGame(userId.value);
    resetUser();
  }
}
