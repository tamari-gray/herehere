import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/models/safety_item.dart';

class Database extends GetxService {
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

  Stream<Game> gameStream() {
    try {
      return _firestore.collection("beta").doc("game").snapshots().map((doc) {
        if (doc.exists) {
          final _game = Game.fromDocumentSnapshot(doc);
          return _game;
        } else {
          return Game.fromDefault();
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> playGame() {
    try {
      return _firestore.collection("beta").doc("game").update({
        'game_phase': EnumToString.convertToString(gamePhase.counting),
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> taggerStartGame() {
    try {
      return _firestore.collection("beta").doc("game").update({
        'game_phase': EnumToString.convertToString(gamePhase.playing),
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<List<Player>> playersStream() {
    try {
      return _firestore
          .collection("beta")
          .doc("game")
          .collection("players")
          .snapshots()
          .map((QuerySnapshot query) {
        List<Player> players = List.empty(growable: true);

        query.docs.forEach((doc) {
          players.add(Player.fromQueryDocumentSnapshot(doc));
        });
        return players;
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<SafetyItem>> availableSafetyItemStream() {
    try {
      return _firestore
          .collection("beta")
          .doc("game")
          .collection("items")
          .where('item_picked_up', isEqualTo: false)
          .snapshots()
          .map((QuerySnapshot query) {
        List<SafetyItem> items = List.empty(growable: true);
        query.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          final lat = data["point"]["geopoint"].latitude as double;
          final long = data["point"]["geopoint"].longitude as double;
          final pickedUp = data["item_picked_up"] ?? false;

          items.add(SafetyItem(doc.id, lat, long, pickedUp));
        });
        return items;
      });
    } catch (e) {
      rethrow;
    }
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

  Future<void> pickUpItem(SafetyItem _item, String playerId) async {
    try {
      await _firestore
          .collection("beta")
          .doc("game")
          .collection("items")
          .doc(_item.id)
          .update({
        'item_picked_up': true,
      });
      await _firestore
          .collection("beta")
          .doc("game")
          .collection("players")
          .doc(playerId)
          .collection("items")
          .add({"time": DateTime.now()});
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> reset() async {
    try {
      await _firestore.collection("beta").doc("game").update({
        'game_phase': EnumToString.convertToString(gamePhase.creating),
      });
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
