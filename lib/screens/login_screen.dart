import 'package:flutter/material.dart';
import '../config/size_config.dart';
import '../widgets/auth_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0084FF), Color(0xFF00C6FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.ws(24)),
            child: Column(
              children: [
                SizedBox(height: SizeConfig.hs(80)),
                Icon(
                  Icons.chat_bubble_outline,
                  size: SizeConfig.fs(80),
                  color: Colors.white,
                ),
                SizedBox(height: SizeConfig.hs(16)),
                Text(
                  'Messenger Chat',
                  style: TextStyle(
                    fontSize: SizeConfig.fs(32),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: SizeConfig.hs(8)),
                Text(
                  'Connect with friends and family',
                  style: TextStyle(
                    fontSize: SizeConfig.fs(16),
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: SizeConfig.hs(60)),
                const AuthForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
