import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Screen/Splash_screen.dart';

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Suggest Me",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
