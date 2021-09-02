import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> joinGame(String username) async {
    try {
      return await _firestore.collection("game").add({
        'dateCreated': Timestamp.now(),
        'username': username,
        'isAdmin': username == 'kawaiifreak97_admin' ? true : false,
      }).then((docref) => docref.id);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
