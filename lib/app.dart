import 'package:flutter/material.dart';

import 'Screen/Splash_screen.dart';
class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Suggest me app",
      debugShowCheckedModeBanner: false,

      home:SplashScreen() ,
    );
  }
}
