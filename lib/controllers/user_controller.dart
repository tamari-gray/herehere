import 'dart:async';

import 'package:get/get.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/services/database.dart';

class UserController extends GetxController {
  final Database _database = Get.find();

  final userId = ''.obs;
  final user = Player("", "", false, false, false).obs;
  final safetyItemTime = 0.obs;
  var locationHiddenTimer = 0.obs;

  void logIn(String id) {
    if (id != '') {
      user.bindStream(_database.userDocStream(id));
      safetyItemTime.bindStream(_database.locationHiddenStream(id));
    }
  }

  void calcLocationSafetyTime() {
    locationHiddenTimer = safetyItemTime;
    Timer.periodic(Duration(seconds: 1), (timer) {
      // ignore: unrelated_type_equality_checks
      if (locationHiddenTimer == 0) {
        timer.cancel();
      }
      // ignore: unnecessary_statements
      locationHiddenTimer--;
    });
  }

  @override
  void onInit() {
    super.onInit();
    ever(userId, (_) => logIn(userId.value));
    ever(safetyItemTime, (_) => calcLocationSafetyTime());
  }
}
