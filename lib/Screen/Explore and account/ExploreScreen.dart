import 'dart:io';

import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/profile%20and%20dashboard/Profile.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  File? profileImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[100],

        title: const Text(
          'Home',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Profile(),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage("assets/images/p3p3.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
