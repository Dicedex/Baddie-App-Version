import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String? recipientImageUrl;

  const ChatScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    this.recipientImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    debugPrint('ChatScreen initState - Current User: ${_currentUser?.uid}');
    debugPrint('ChatScreen initState - Recipient ID: ${widget.recipientId}');
    
    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to chat.')),
          );
        }
      });
    }
    // Don't mark as read on init to avoid blocking
    // Just load the chat UI
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) {
      return;
    }

    final String messageText = _messageController.text.trim();
    _messageController.clear();

    final ChatMessage newMessage = ChatMessage(
      senderId: _currentUser!.uid,
      text: messageText,
      read: false,
      time: DateTime.now(),
    );

    final String chatId = _getChatId();

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(newMessage.toMap());

      final chatData = {
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': [_currentUser!.uid, widget.recipientId],
      };

      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('chats')
          .doc(widget.recipientId)
          .set(chatData, SetOptions(merge: true));
      await _firestore
          .collection('users')
          .doc(widget.recipientId)
          .collection('chats')
          .doc(_currentUser!.uid)
          .set(chatData, SetOptions(merge: true));

      // Scroll to bottom after sending message
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  String _getChatId() {
    final List<String> participants = [_currentUser!.uid, widget.recipientId];
    participants.sort();
    return participants.join('_');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('User not logged in.')),
      );
    }

    final String chatId = _getChatId();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.recipientImageUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.recipientImageUrl!),
                radius: 20,
              )
            else
              const CircleAvatar(
                child: Icon(Icons.person),
                radius: 20,
              ),
            const SizedBox(width: 12),
            Text(widget.recipientName),
          ],
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  debugPrint('StreamBuilder error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading messages',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet. Start the conversation!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs
                    .map((doc) {
                      try {
                        return ChatMessage.fromMap(doc.data() as Map<String, dynamic>);
                      } catch (e) {
                        debugPrint('Error parsing message: $e');
                        return null;
                      }
                    })
                    .whereType<ChatMessage>()
                    .toList();

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderId == _currentUser!.uid;
                    final String timeString =
                        DateFormat('HH:mm').format(message.time);

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.blueAccent
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message.text ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: Text(
                              timeString,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message Input Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[300]!,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
