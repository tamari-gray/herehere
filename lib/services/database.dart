import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:cysm/models/game.dart';
import 'package:cysm/models/player.dart';
import 'package:cysm/models/safety_item.dart';

class Database extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> gameRef() =>
      _firestore.collection("beta").doc("game");

  CollectionReference<Map<String, dynamic>> itemsRef() =>
      gameRef().collection("items");

  CollectionReference<Map<String, dynamic>> playersRef() =>
      gameRef().collection("players");

  DocumentReference<Map<String, dynamic>> playerRef(String id) =>
      playersRef().doc(id);

  newPlayer(String _username, bool _isAdmin, GeoPoint _location,
          double _locationAccuracy) =>
      {
        'dateCreated': Timestamp.now(),
        'username': _username,
        'is_admin': _isAdmin,
        'is_tagger': false,
        'has_been_tagged': false,
        'location_hidden': false,
        'location': _location,
        'location_accuracy': _locationAccuracy
      };

  Stream<Player> userDocStream(String userId) {
    return playerRef(userId).snapshots().map((doc) {
      if (doc.exists) {
        return Player.fromDocumentSnapshot(doc);
      } else {
        return Player.fromDefault();
      }
    });
  }

  Future<String> joinGame(String username, bool isAdmin, GeoPoint location,
      {double locationAccuracy: 0.0}) async {
    try {
      return await playersRef()
          .add(newPlayer(username, isAdmin, location, locationAccuracy))
          .then((docref) {
        return docref.id;
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> leaveGame(String id) async {
    try {
      return await playerRef(id).delete();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      return await itemsRef().doc(id).delete();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<Game> gameStream() {
    try {
      return gameRef().snapshots().map((doc) {
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
      return gameRef().update({
        'game_phase': EnumToString.convertToString(gamePhase.counting),
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> taggerStartGame() {
    try {
      return gameRef().update({
        'game_phase': EnumToString.convertToString(gamePhase.playing),
        'start_time': DateTime.now().millisecondsSinceEpoch
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<List<Player>> playersStream() {
    try {
      return playersRef().snapshots().map((QuerySnapshot query) {
        List<Player> players = List.empty(growable: true);
        query.docs.forEach(
            (doc) => players.add(Player.fromQueryDocumentSnapshot(doc)));
        return players;
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<SafetyItem>> availableSafetyItemStream() {
    try {
      return itemsRef()
          .where('item_picked_up', isEqualTo: false)
          .snapshots()
          .map((QuerySnapshot query) {
        List<SafetyItem> items = List.empty(growable: true);
        query.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          final lat = data["point"]["geopoint"].latitude as double;
          final long = data["point"]["geopoint"].longitude as double;
          final location =
              Position.fromMap({'latitude': lat, 'longitude': long});

          items.add(SafetyItem(doc.id, location));
        });
        return items;
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<DateTime>> pickedUpItemsStream(String playerId) {
    try {
      return playerRef(playerId)
          .collection("items")
          .snapshots()
          .map((QuerySnapshot query) {
        return query.docs.map((doc) {
          final data = doc.data()! as Map<String, dynamic>;
          final _time = data["time_picked_up"] as int;
          final _timePickedUpAsDate =
              DateTime.fromMicrosecondsSinceEpoch(_time);
          return _timePickedUpAsDate;
        }).toList();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> chooseTagger(String _playerId, bool alreadyTagger) async {
    if (!alreadyTagger) {
      try {
        return await playerRef(_playerId).update({'is_tagger': true});
      } catch (e) {
        print(e);
        rethrow;
      }
    } else {
      try {
        return await playerRef(_playerId).update({'is_tagger': false});
      } catch (e) {
        print(e);
        rethrow;
      }
    }
  }

  Future<void> hiderItemsExpire(String _playerId) async {
    try {
      await playerRef(_playerId).update({'location_hidden': false});
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> pickUpItems(List<SafetyItem> _items, String _playerId) async {
    try {
      _items.forEach((_item) async {
        await itemsRef().doc(_item.id).update({'item_picked_up': true});
        await playerRef(_playerId).update({'location_hidden': true});
        await playerRef(_playerId)
            .collection("items")
            .add({"time_picked_up": DateTime.now().microsecondsSinceEpoch});
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> tagHiders(List<Player> _hiders) async {
    try {
      _hiders.forEach((_hider) async =>
          await playerRef(_hider.id).update({'has_been_tagged': true}));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateUserLocation(String _hiderId, Position _location) async {
    print(_location.accuracy);

    try {
      return await playerRef(_hiderId).update({
        'location': GeoPoint(_location.latitude, _location.longitude),
        'location_accuracy': _location.accuracy
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> reset() async {
    try {
      await gameRef().update({
        'game_phase': EnumToString.convertToString(gamePhase.creating),
      });
      await playersRef().get().then(
          (snap) => snap.docs.forEach((doc) async => await leaveGame(doc.id)));
      return itemsRef().get().then(
          (snap) => snap.docs.forEach((doc) async => await deleteItem(doc.id)));
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
