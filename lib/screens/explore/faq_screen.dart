import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  // Professional solid color palette
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How do I upload a suggestion?',
      'answer': 'Tap the upload button (+) on the home screen. Fill in the course details, select your file, and tap Submit. You must be logged in to upload.'
    },
    {
      'question': 'How do I search for suggestions?',
      'answer': 'Use the search bar at the top of the Explore screen. You can search by course name or course code.'
    },
    {
      'question': 'How do I download an attachment?',
      'answer': 'Find the suggestion card and tap "Download". You need to be logged in to access the download link.'
    },
    {
      'question': 'Do I need an account to browse?',
      'answer': 'You can browse and search suggestions without an account, but you need to log in to upload, download materials, and access your profile.'
    },
    {
      'question': 'How do I edit my profile?',
      'answer': 'Open the side menu (drawer) and tap "Edit Profile". You can update your department, intake, and section there.'
    },
    {
      'question': 'How do I change my password?',
      'answer': 'Go to Settings from the drawer menu to update your password.'
    },
    {
      'question': 'Is this app free to use?',
      'answer': 'Yes, Suggest Me is a community platform for students to share resources freely.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Theme(
              data: ThemeData().copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  _faqs[index]['question']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                iconColor: _primaryColor,
                collapsedIconColor: _primaryColor,
                childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                children: [
                  Text(
                    _faqs[index]['answer']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
