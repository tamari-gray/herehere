import 'package:get/get.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/services/database.dart';

class GameController extends GetxController {
  final Database _database = Get.put(Database());
  final game = Game.fromDefault().obs;
  final players = List<Player>.empty().obs;

  @override
  void onInit() {
    super.onInit();
    game.bindStream(_database.gameStream());
    players.bindStream(_database.playersStream());
  }

  void showTaggerIsComingDialog() {
    Get.defaultDialog(
        title: 'Tagger is coming!',
        textConfirm: 'Ok',
        middleText: 'Find safety items to hide your location from them!',
        onConfirm: () async {
          Get.back();
          game.value.showTaggerIsComing = false;
        });
  }
}
