import 'package:get/get.dart';

class GameController extends GetxController {
  final phase = gamePhase.initialising.obs;
}

enum gamePhase { initialising, playing, finished }
