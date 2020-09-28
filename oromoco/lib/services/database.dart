import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oromoco/helper/constants.dart';

class DatabaseMethods{
  Future<QuerySnapshot> getUserByUsername(String username) async {
    return await Firestore.instance
        .collection("users")
        .where("name", isEqualTo: username)
        .getDocuments();
  }

  Future<QuerySnapshot> getUserByUserEmail(String userEmail) async {
    return await Firestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .getDocuments();
  }

  Future<DocumentReference> uploadUserInfo(userMap) {
    return Firestore.instance.collection("users").add(userMap);
  }

  addConversationMessage(messageMap) {
    Firestore.instance
        .collection("chatRoom")
        .document(Constants.email)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> resetMessageNotification() {
    return Firestore.instance
        .collection("users")
        .document(Constants.firebase_uid)
        .updateData({'hasNewMessage': false});
  }

  Future<void> resetBroadcastNotification() {
    return Firestore.instance
        .collection("users")
        .document(Constants.firebase_uid)
        .updateData({'hasNewBroadcast': false});
  }

  Future<void> updateUserChattingWith(String sendTo) {
    return Firestore.instance
        .collection("users")
        .document(Constants.firebase_uid)
        .updateData({'chattingWith': sendTo});
  }

  Future<void> updateUserUid(String uid) {
    return Firestore.instance.collection("users").document(uid).updateData({
      'id': uid,
    });
  }

  Future<void> updateUserToken(String token, String uid) {
    return Firestore.instance.collection("users").document(uid).updateData({
      'token': token,
    });
  }

  Future<void> updateUserMissingField(String uid, String key, dynamic value) {
    return Firestore.instance.collection("users").document(uid).updateData({
      key: value
    });
  }

  createChatRoom(chatRoomMap) {
    Firestore.instance
        .collection("chatRoom")
        .document(Constants.email)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(int messageLimit) async {
    return await Firestore.instance
        .collection("chatRoom")
        .document(Constants.email)
        .collection("chats")
        .orderBy("time", descending: true)
        .limit(messageLimit)
        .snapshots();
  }

  getBroadcasts() async {
    return await Firestore.instance
      .collectionGroup("broadcasts")
      .where("users", arrayContains: Constants.firebase_uid)
      .orderBy("time", descending: true)
      .limit(20)
      .snapshots();
  }
}