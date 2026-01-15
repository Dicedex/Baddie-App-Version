import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> chatStream(String matchId) {
    return _db
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  Future<void> sendMessage(String matchId, ChatMessage msg) async {
    await _db
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .add(msg.toMap());
  }
}
