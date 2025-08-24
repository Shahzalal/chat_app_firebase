import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/size_config.dart';
import '../widgets/user_tile.dart';

import '../widgets/search_bar.dart'; // এখানে CustomSearchBar আছে
import 'chat_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Contacts',
          style: TextStyle(
            fontSize: SizeConfig.fs(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: SizeConfig.fs(24)),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Custom Search Bar ব্যবহার করা হচ্ছে
          Padding(
            padding: EdgeInsets.all(SizeConfig.ws(16)),
            child: CustomSearchBar(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
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
                      'Error loading users',
                      style: TextStyle(fontSize: SizeConfig.fs(16)),
                    ),
                  );
                }

                final users = snapshot.data?.docs ?? [];
                final currentUserId = _auth.currentUser?.uid;

                // Filter out current user and apply search filter
                final filteredUsers = users.where((user) {
                  if (user.id == currentUserId) return false;

                  final userData = user.data() as Map<String, dynamic>;
                  final username =
                      userData['username']?.toString().toLowerCase() ?? '';
                  final email =
                      userData['email']?.toString().toLowerCase() ?? '';

                  if (_searchQuery.isEmpty) return true;

                  return username.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group,
                          size: SizeConfig.fs(64),
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: SizeConfig.hs(16)),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No other users yet'
                              : 'No users found',
                          style: TextStyle(
                            fontSize: SizeConfig.fs(18),
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: SizeConfig.hs(8)),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Tell others to join the app!'
                              : 'Try a different search term',
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
                  padding: EdgeInsets.only(bottom: SizeConfig.hs(16)),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user =
                        filteredUsers[index].data() as Map<String, dynamic>;
                    return UserTile(
                      user: user,
                      userId: filteredUsers[index].id,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              receiverId: filteredUsers[index].id,
                              receiverName: user['username'] ?? user['email'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
