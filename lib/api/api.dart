import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hichat/models/chat_user_model.dart';
import 'package:hichat/models/message_model.dart';

class Api {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static late ChatUser me;

  static User get user => auth.currentUser!;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<bool> isUsernameAvailable(String username) async {
    final snapshot = await firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (snapshot.docs.isNotEmpty) {
      if (snapshot.docs.first.id == user.uid) return true;

      return false;
    }

    return true;
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'username': me.username,
      'image': me.image,
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((
      p0,
    ) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    me.image = await ref.getDownloadURL();

    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<ChatUser?> getUserByUsername(String username) async {
    final snapshot = await firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return ChatUser.fromJson(snapshot.docs.first.data());
    }

    return null;
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName ?? '',
      username: '',
      email: user.email ?? '',
      image: user.photoURL ?? '',
      createdAt: time,
      isOnline: false,
      lastActive: time,
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Future<void> updateEmail(String newEmail) async {
    await user.verifyBeforeUpdateEmail(newEmail);

    me.email = newEmail;

    await firestore.collection('users').doc(user.uid).update({
      'email': newEmail,
    });
  }

  static Future<void> updatePassword(String newPassword) async {
    await user.updatePassword(newPassword);
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,

      'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser chatUser,
  ) {
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
    ChatUser chatUser,
    String msg,
    MessageType type,
  ) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
      toId: chatUser.id,
      msg: msg,
      read: '',
      type: type,
      fromId: user.uid,
      sent: time,
    );

    final ref = firestore.collection(
      'chats/${getConversationID(chatUser.id)}/messages/',
    );
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
