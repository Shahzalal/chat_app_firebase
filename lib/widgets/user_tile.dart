import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/size_config.dart';

class UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final String userId;
  final VoidCallback onTap;

  const UserTile({
    super.key,
    required this.user,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF0084FF),
        radius: SizeConfig.ws(24),
        child: Text(
          user['username']?.toString().substring(0, 1).toUpperCase() ??
              user['email']?.toString().substring(0, 1).toUpperCase() ??
              'U',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.fs(16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user['username'] ?? user['email'] ?? 'Unknown User',
        style: TextStyle(
          fontSize: SizeConfig.fs(16),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
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
            style: TextStyle(fontSize: SizeConfig.fs(12), color: Colors.grey),
          );
        },
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.ws(12),
          vertical: SizeConfig.hs(6),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0084FF),
          borderRadius: BorderRadius.circular(SizeConfig.ws(16)),
        ),
        child: Text(
          'Message',
          style: TextStyle(
            fontSize: SizeConfig.fs(12),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
