import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/size_config.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
  }

  void _setupPushNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? 'New message'),
          backgroundColor: const Color(0xFF0084FF),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when app is opened from a notification
    });
  }

  String _getChatId() {
    final currentUserId = _auth.currentUser!.uid;
    final receiverId = widget.receiverId;

    // Create a consistent chat ID regardless of user order
    return currentUserId.compareTo(receiverId) < 0
        ? '$currentUserId-$receiverId'
        : '$receiverId-$currentUserId';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final chatId = _getChatId();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.receiverName,
              style: TextStyle(
                fontSize: SizeConfig.fs(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(widget.receiverId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final isOnline = userData['isOnline'] ?? false;
                  return Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: SizeConfig.fs(12),
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  );
                }
                return Text(
                  'Offline',
                  style: TextStyle(
                    fontSize: SizeConfig.fs(12),
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFF0F2F5),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF0084FF),
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading messages',
                        style: TextStyle(fontSize: SizeConfig.fs(16)),
                      ),
                    );
                  }

                  final messages = snapshot.data?.docs ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: SizeConfig.fs(64),
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: SizeConfig.hs(16)),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: SizeConfig.fs(18),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: SizeConfig.hs(8)),
                          Text(
                            'Say hello to ${widget.receiverName}!',
                            style: TextStyle(
                              fontSize: SizeConfig.fs(14),
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: EdgeInsets.all(SizeConfig.ws(8)),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          messages[index].data() as Map<String, dynamic>;
                      final isMe =
                          message['senderId'] == _auth.currentUser?.uid;

                      return MessageBubble(message: message, isMe: isMe);
                    },
                  );
                },
              ),
            ),
          ),
          ChatInput(
            onSendMessage: (text) async {
              if (text.trim().isEmpty) return;

              final user = _auth.currentUser;
              if (user == null) return;

              try {
                final chatId = _getChatId();

                // Create or update the chat document
                await _firestore.collection('chats').doc(chatId).set({
                  'participants': [user.uid, widget.receiverId],
                  'lastMessage': text,
                  'lastMessageTime': Timestamp.now(),
                }, SetOptions(merge: true));

                // Add the message to the subcollection
                await _firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .add({
                      'text': text.trim(),
                      'senderId': user.uid,
                      'senderEmail': user.email,
                      'receiverId': widget.receiverId,
                      'timestamp': Timestamp.now(),
                    });

                // Send push notification to the receiver
                final receiverDoc = await _firestore
                    .collection('users')
                    .doc(widget.receiverId)
                    .get();
                if (receiverDoc.exists) {
                  final receiverData =
                      receiverDoc.data() as Map<String, dynamic>;
                  final fcmToken = receiverData['fcmToken'];

                  if (fcmToken != null) {
                    // In a real app, you would send this to your server
                    // or use Firebase Cloud Functions to send the notification
                    print('Would send notification to: $fcmToken');
                  }
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to send message')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
