import 'dart:async';
import 'package:flutter/material.dart';
import 'Explore and account/explore_screen.dart';
import 'choice_screen.dart';
import 'log and reg/Services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () async {
      final loggedIn = await _authService.isLoggedIn();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => loggedIn ? ExploreScreen() : const ChoiceScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            Image(image: AssetImage('assets/images/p2.png'), width: 200,fit:BoxFit.contain,),

            SizedBox(height: 20),
            Text(
              "Suggestion Sharing\n\t\t\t\t\t\t\t\tPlatform",
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "This productive tool is designed to help\n\t\t\t\t\t\tyou better share your suggestion\n\t\t\t\t\t\t\t\tdepartment-wise conveniently! ",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
