import 'package:get/get.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/services/database.dart';

class GameController extends GetxController {
  final phase = gamePhase.initialising.obs;
  final players = List<Player>.empty().obs;

  @override
  void onInit() {
    super.onInit();
    phase.bindStream(Database().gamePhaseStream());
    players.bindStream(Database().playersStream());
  }
}

enum gamePhase { initialising, playing, finished }
