import 'package:flutter/material.dart';
import 'Screen/splash_screen.dart';
class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(


      debugShowCheckedModeBanner: false,
      title: 'Suggestion Sharing App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: SplashScreen(),


    );
  }
}

