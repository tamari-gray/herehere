import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

// ignore: camel_case_types
enum gamePhase { creating, counting, playing, finished }

class GeneratingItems {
  bool generating = false;
  DateTime time = DateTime(1);

  GeneratingItems(
    this.generating,
    this.time,
  );
}

class Game {
  String id = "";
  DateTime startTime = DateTime.now();
  gamePhase phase = gamePhase.creating;
  GeneratingItems generatingItems = GeneratingItems(false, DateTime(1));
  String justTaggedPlayers = "";

  Game(
    this.id,
    this.startTime,
    this.phase,
    this.generatingItems,
  );

  Map<String, Object?> defaultGame() => {
        'game_phase': gamePhase.creating,
      };

  Game.fromDefault() {
    phase = gamePhase.creating;
  }

  Game.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    phase = EnumToString.fromString(
            gamePhase.values, doc["game_phase"].toString()) ??
        gamePhase.creating;
    startTime = DateTime.fromMillisecondsSinceEpoch(doc['start_time']);
    justTaggedPlayers = doc["just_tagged_players"] ?? "";
    generatingItems = GeneratingItems(
      doc["generating_items"]!["generating"] ?? false,
      (doc["generating_items"]!["time"] as Timestamp).toDate(),
    );
  }
}
