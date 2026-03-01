import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutHelpScreen extends StatelessWidget {
  const AboutHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text(
          'About & Help',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5C2D91),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── About Section ──
            _buildAboutCard(),

            const SizedBox(height: 20),

            // ── FAQ Section ──
            _buildFaqSection(),

            const SizedBox(height: 20),

            // ── Contact Section ──
            _buildContactCard(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─────────────────── ABOUT CARD ───────────────────
  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF5C2D91),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5C2D91).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 42,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Suggest Me',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C2D91),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'A platform where students can share and discover exam suggestions, notes, and study materials. Upload your suggestions to help others and explore resources shared by the community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── FAQ SECTION ───────────────────
  Widget _buildFaqSection() {
    final List<Map<String, String>> faqs = [
      {
        'question': 'How do I upload a suggestion?',
        'answer':
            'Tap the upload button (floating button at the bottom right) on the Home screen. Fill in the course details, select your file, and tap Submit. Your suggestion will be visible to everyone!',
      },
      {
        'question': 'How do I search for suggestions?',
        'answer':
            'Use the search bar at the top of the Home screen. You can search by course name or course code to quickly find what you need.',
      },
      {
        'question': 'How do I download an attachment?',
        'answer':
            'Find the suggestion card you want and tap the "Download" link at the bottom of the card. The file will open in your browser for download. You need to be logged in to download.',
      },
      {
        'question': 'Do I need an account to browse?',
        'answer':
            'You can browse and view suggestions without an account. However, you need to log in to upload suggestions, download attachments, and access your profile.',
      },
      {
        'question': 'How do I edit my profile?',
        'answer':
            'Open the side menu (drawer) and tap "Edit Profile". You can update your name, department, intake, and section from there.',
      },
      {
        'question': 'How do I change my password?',
        'answer':
            'Go to Settings from the drawer menu. You will find the "Change Password" section where you can update your password.',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.quiz_outlined, color: Color(0xFF5C2D91), size: 24),
              SizedBox(width: 8),
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C2D91),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...faqs.map((faq) => _buildFaqTile(faq['question']!, faq['answer']!)),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 14),
          iconColor: const Color(0xFF5C2D91),
          collapsedIconColor: const Color(0xFF5C2D91),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── CONTACT CARD ───────────────────
  Widget _buildContactCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.contact_support_outlined,
                  color: Color(0xFF5C2D91), size: 24),
              SizedBox(width: 8),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C2D91),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Have a question or need help? Reach out to us!',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Email row
          InkWell(
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: 'support@suggestme.app',
                query: 'subject=Help Request - Suggest Me App',
              );
              try {
                await launchUrl(uri);
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open email client.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.email_outlined, color: Color(0xFF5C2D91), size: 22),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'support@suggestme.app',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5C2D91),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Developer info row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.code, color: Color(0xFF5C2D91), size: 22),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Suggest Me Team',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5C2D91),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
