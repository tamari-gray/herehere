import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum niiraStage { initialising, playing, finished }
enum playingPhase { counting, seek, hide }

// Todo:
// pass 'startTime' value into constructors

class Game {
  String id = "";
  DateTime startTime = DateTime.now();
  double findItemTime = 5;
  double taggerPowerUpTime = 3;
  niiraStage stage = niiraStage.initialising;
  playingPhase phase = playingPhase.counting;

  Game(
    this.id,
    this.startTime,
    this.findItemTime,
    this.taggerPowerUpTime,
    this.stage,
    this.phase,
  );

  Map<String, Object?> defaultGame() => {
        'find_item_time': 5,
        'tagger_power_up_time': 3,
        'niira_stage': niiraStage.initialising,
        'playing_phase': playingPhase.counting
      };

  Game.fromDefault() {
    findItemTime = 5;
    taggerPowerUpTime = 3;
    stage = niiraStage.initialising;
    phase = playingPhase.counting;
  }

  Game.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    id = doc.id;
    findItemTime = doc["find_item_time"] ?? 3;
    taggerPowerUpTime = doc["tagger_power_up_time"] ?? 5;
    stage = EnumToString.fromString(
            niiraStage.values, doc["niira_stage"].toString()) ??
        niiraStage.initialising;
    phase = doc["playing_phase"] ?? false;
  }

  Game.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    findItemTime = double.parse(doc["find_item_time"].toString());
    taggerPowerUpTime = double.parse(doc["tagger_power_up_time"].toString());
    stage = EnumToString.fromString(
            niiraStage.values, doc["niira_stage"].toString()) ??
        niiraStage.initialising;
    phase = EnumToString.fromString(
            playingPhase.values, doc["playing_phase"].toString()) ??
        playingPhase.counting;
  }
}
