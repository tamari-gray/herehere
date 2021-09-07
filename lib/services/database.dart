import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/models/player.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Player> userDocStream(String userId) {
    return _firestore
        .collection("beta")
        .doc("game")
        .collection("players")
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Player.fromDocumentSnapshot(doc);
      } else {
        return Player.fromDefault();
      }
    });
  }

  Future<String> joinGame(String username, bool isAdmin) async {
    try {
      return await _firestore
          .collection("beta")
          .doc("game")
          .collection("players")
          .add({
        'dateCreated': Timestamp.now(),
        'username': username,
        'is_admin': isAdmin,
        'is_tagger': false,
        'is_hider': false,
        'has_been_tagged': false,
        'has_immunity': false
      }).then((docref) {
        return docref.id;
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> leaveGame(String id) async {
    try {
      return await _firestore
          .collection("beta")
          .doc("game")
          .collection("players")
          .doc(id)
          .delete();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<gamePhase> gamePhaseStream() {
    return _firestore.collection("beta").doc("game").snapshots().map((doc) {
      if (doc.exists) {
        final docData = doc.data();
        final String phase = docData!['game_phase'].toString();

        if (phase == 'gamePhase.initialising') {
          return gamePhase.initialising;
        } else if (phase == 'gamePhase.playing') {
          return gamePhase.playing;
        } else if (phase == 'gamePhase.finished') {
          return gamePhase.finished;
        } else {
          return gamePhase.initialising;
        }
      } else {
        return gamePhase.initialising;
      }
    });
  }

  Future<void> updateGamePhase(gamePhase phase) {
    try {
      return _firestore
          .collection("beta")
          .doc("game")
          .update({'game_phase': phase.toString()});
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<List<Player>> playersStream() {
    return _firestore
        .collection("beta")
        .doc("game")
        .collection("players")
        .snapshots()
        .map((QuerySnapshot query) {
      List<Player> players = List.empty(growable: true);

      query.docs.forEach((doc) {
        // final data = doc.data()! as Map<String, dynamic>;
        // players.add(Player(id: doc.id, username: data['username'].toString(), ));
        players.add(Player.fromQueryDocumentSnapshot(doc));
      });
      return players;
    });
  }

  Future<void> chooseTagger(String playerId, bool alreadyTagger) async {
    if (!alreadyTagger) {
      try {
        return await _firestore
            .collection("beta")
            .doc("game")
            .collection("players")
            .doc(playerId)
            .update({
          'is_tagger': true,
        });
      } catch (e) {
        print(e);
        rethrow;
      }
    } else {
      try {
        return await _firestore
            .collection("beta")
            .doc("game")
            .collection("players")
            .doc(playerId)
            .update({
          'is_tagger': false,
        });
      } catch (e) {
        print(e);
        rethrow;
      }
    }
  }

  Future<void> reset() async {
    try {
      return await _firestore
          .collection("beta")
          .doc("game")
          .collection("players")
          .get()
          .then((snap) {
        snap.docs.forEach((doc) async {
          await _firestore
              .collection("beta")
              .doc("game")
              .collection("players")
              .doc(doc.id)
              .delete();
        });
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
