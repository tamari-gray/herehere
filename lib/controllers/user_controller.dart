import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/services/database.dart';

class UserController extends GetxController {
  final Database _database = Get.find();

  var userId = ''.obs;
  final user = Player.fromDefault().obs;
  final safetyItemTime = 0.obs;
  var locationHiddenTimer = 0.obs;

  void logIn(String id) {
    if (id != '') {
      user.bindStream(_database.userDocStream(id));
      safetyItemTime.bindStream(_database.locationHiddenStream(id));
    }
  }

  Future<void> joinGame(
      String _username, bool isAdmin, GeoPoint _location) async {
    userId.value = await _database.joinGame(_username, true, _location);
  }

  void calcLocationSafetyTime() {
    locationHiddenTimer = safetyItemTime;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (locationHiddenTimer.value == 0) {
        timer.cancel();
      }
      locationHiddenTimer.value--;
    });
  }

  @override
  void onInit() {
    super.onInit();
    ever(userId, (_) => logIn(userId.value));
    ever(safetyItemTime, (_) => calcLocationSafetyTime());
  }

  void resetUser() => userId = "".obs;

  Future<void> leaveGame() async {
    await _database.leaveGame(userId.value);
    resetUser();
  }
}
