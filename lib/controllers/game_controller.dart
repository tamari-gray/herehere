import 'package:get/get.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/services/database.dart';

class GameController extends GetxController {
  final game = Game.fromDefault().obs;
  final players = List<Player>.empty().obs;

  @override
  void onInit() {
    super.onInit();
    game.bindStream(Database().gameStream());
    players.bindStream(Database().playersStream());
  }
}
