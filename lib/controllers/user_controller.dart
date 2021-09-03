import 'package:get/get.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/services/database.dart';

class UserController extends GetxController {
  final userId = ''.obs;
  final user = Player("", "", false, false, false, false, false).obs;
  final db = Database();

  void logIn(String id) {
    if (id != '') user.bindStream(db.userDocStream(id));
  }

  @override
  void onInit() {
    super.onInit();
    ever(userId, (_) => logIn(userId.value));
  }
}
