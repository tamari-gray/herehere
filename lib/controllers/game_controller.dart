import 'package:get/get.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/services/database.dart';

class GameController extends GetxController {
  final Database _database = Get.find();
  final game = Game.fromDefault().obs;
  final players = List<Player>.empty().obs;

  @override
  void onInit() {
    super.onInit();
    game.bindStream(_database.gameStream());
    players.bindStream(_database.playersStream());
  }
}
