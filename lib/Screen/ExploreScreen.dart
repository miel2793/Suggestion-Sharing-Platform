import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      appBar: AppBar(title: const Text("Explore Suggestions")),
      body: const Center(
        child: Text(
          "Public Suggestions will appear here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
