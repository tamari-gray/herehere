import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
// import 'package:geolocator/geolocator.dart';

enum gamePhase { creating, counting, playing, finished }

// Todo:
// pass 'startTime' value into constructors

class Game {
  String id = "";
  DateTime startTime = DateTime.now();
  gamePhase phase = gamePhase.creating;
  // Position location =

  Game(
    this.id,
    this.startTime,
    this.phase,
    // this.location,
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
    startTime = DateTime.fromMillisecondsSinceEpoch(doc['start_time']);
  }

  Game.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    phase = EnumToString.fromString(
            gamePhase.values, doc["game_phase"].toString()) ??
        gamePhase.creating;
  }
}
