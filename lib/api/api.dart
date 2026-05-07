import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hichat/models/chat_user_model.dart';

class Api {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore.collection('users').snapshots();
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
}
