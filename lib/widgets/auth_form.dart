import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/size_config.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // Validate username
        if (_usernameController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a username')),
          );
          return;
        }

        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );

        // Save user info to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
              'username': _usernameController.text,
              'email': _emailController.text,
              'isOnline': true,
              'createdAt': Timestamp.now(),
            });

        // Request notification permissions
        await FirebaseMessaging.instance.requestPermission();

        // Get FCM token and save it
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .update({'fcmToken': fcmToken});
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      padding: EdgeInsets.all(SizeConfig.ws(24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.ws(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!_isLogin)
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username (will be visible to others)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.ws(12)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.ws(16),
                  vertical: SizeConfig.hs(14),
                ),
              ),
            ),
          if (!_isLogin) SizedBox(height: SizeConfig.hs(16)),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeConfig.ws(12)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: SizeConfig.ws(16),
                vertical: SizeConfig.hs(14),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: SizeConfig.hs(16)),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeConfig.ws(12)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: SizeConfig.ws(16),
                vertical: SizeConfig.hs(14),
              ),
            ),
            obscureText: true,
          ),
          SizedBox(height: SizeConfig.hs(24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0084FF),
                padding: EdgeInsets.symmetric(vertical: SizeConfig.hs(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.ws(12)),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: SizeConfig.hs(20),
                      width: SizeConfig.hs(20),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isLogin ? 'Login' : 'Sign Up',
                      style: TextStyle(
                        fontSize: SizeConfig.fs(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: SizeConfig.hs(16)),
          TextButton(
            onPressed: () => setState(() => _isLogin = !_isLogin),
            child: Text(
              _isLogin
                  ? 'Don\'t have an account? Sign Up'
                  : 'Already have an account? Login',
              style: TextStyle(
                fontSize: SizeConfig.fs(14),
                color: const Color(0xFF0084FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
