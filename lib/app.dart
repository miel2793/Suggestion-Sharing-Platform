import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/LoginScreen.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/SingupScreen.dart';
import 'package:suggestion_sharing_platform/card.dart';
import 'Screen/Splash_screen.dart';
class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Suggest me app",
      debugShowCheckedModeBanner: false,

      home:SuggestionCard() ,
    );
  }
}
