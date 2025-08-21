import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get users stream
  static Stream<QuerySnapshot> getUsers() {
    return _firestore.collection('users').snapshots();
  }

  // Get messages for a specific chat
  static Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send message to a specific user
  static Future<void> sendMessage({
    required String text,
    required String receiverId,
  }) async {
    if (text.trim().isEmpty || _auth.currentUser == null) return;

    final currentUserId = _auth.currentUser!.uid;
    final chatId = currentUserId.compareTo(receiverId) < 0
        ? '$currentUserId-$receiverId'
        : '$receiverId-$currentUserId';

    // Create or update the chat document
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, receiverId],
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
          'senderId': currentUserId,
          'senderEmail': _auth.currentUser!.email,
          'receiverId': receiverId,
          'timestamp': Timestamp.now(),
        });

    // Send push notification to the receiver
    final receiverDoc = await _firestore
        .collection('users')
        .doc(receiverId)
        .get();
    if (receiverDoc.exists) {
      final receiverData = receiverDoc.data() as Map<String, dynamic>;
      final fcmToken = receiverData['fcmToken'];

      if (fcmToken != null) {
        // In a real app, you would send this to your server
        // or use Firebase Cloud Functions to send the notification
        print('Would send notification to: $fcmToken');
      }
    }
  }

  // Setup push notifications
  static void setupPushNotifications(void Function(RemoteMessage) onMessage) {
    _messaging.requestPermission();
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  // Save user data
  static Future<void> saveUserData(
    String userId,
    String username,
    String email,
  ) async {
    await _firestore.collection('users').doc(userId).set({
      'username': username,
      'email': email,
      'isOnline': true,
      'createdAt': Timestamp.now(),
    }, SetOptions(merge: true));

    // Get FCM token and save it
    final fcmToken = await _messaging.getToken();
    if (fcmToken != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
      });
    }
  }

  // Update user online status
  static Future<void> updateUserStatus(bool isOnline) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': Timestamp.now(),
      });
    }
  }
}
