import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum gamePhase { creating, counting, playing, finished }

// Todo:
// pass 'startTime' value into constructors

class Game {
  String id = "";
  DateTime startTime = DateTime.now();
  gamePhase phase = gamePhase.creating;

  Game(
    this.id,
    this.startTime,
    this.phase,
  );

  Map<String, Object?> defaultGame() => {
        'game_phase': gamePhase.creating,
      };

  Game.fromDefault() {
    phase = gamePhase.creating;
  }

  Game.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    id = doc.id;
    phase = EnumToString.fromString(
            gamePhase.values, doc["game_phase"].toString()) ??
        gamePhase.creating;
  }

  Game.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    phase = EnumToString.fromString(
            gamePhase.values, doc["game_phase"].toString()) ??
        gamePhase.creating;
  }
}
