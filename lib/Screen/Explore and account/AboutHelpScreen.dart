import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutHelpScreen extends StatelessWidget {
  const AboutHelpScreen({super.key});

  // Professional solid color palette
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _errorColor = Color(0xFFEF4444);
  static const _cardBgLight = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        title: const Text(
          'About & Help',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAboutCard(),
            const SizedBox(height: 20),
            _buildContactCard(context),
            const SizedBox(height: 20),
            _buildHelpCard(context),
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
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
              color: _primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Suggest Me',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'A platform where students can share and discover exam suggestions, notes, and study materials. Upload your suggestions to help others and explore resources shared by the community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── CONTACT CARD ───────────────────
  Widget _buildContactCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
                  color: _primaryColor, size: 24),
              SizedBox(width: 10),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Have questions or need help? Reach out to us.',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Email tile (interactive)
          InkWell(
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'mailto',
                path: 'mahmudsifat2793@gmail.com',
                queryParameters: {
                  'subject': 'Help Request - Suggest Me App',
                },
              );
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch email client';
                }
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Could not open email client.'),
                    backgroundColor: _errorColor,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor, width: 0.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.email_outlined, color: _primaryColor, size: 22),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'mahmudsifat2793@gmail.com',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Secondary Academic Contact
          InkWell(
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'mailto',
                path: 'anasibnbelal@gmail.com',
                queryParameters: {
                  'subject': 'Help Request - Suggest Me App',
                },
              );
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch email client';
                }
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Could not open email client.'),
                    backgroundColor: _errorColor,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _cardBgLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor, width: 0.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.email_outlined, color: _primaryColor, size: 22),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'anasibnbelal@gmail.com',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Developer info (non-interactive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _cardBgLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor, width: 0.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.code, color: _primaryColor, size: 22),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Developer',
                        style: TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Suggest Me Team',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── HELP CARD (FAQ / Resources) ───────────────────
  Widget _buildHelpCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline, color: _primaryColor, size: 24),
              SizedBox(width: 10),
              Text(
                'Quick Help',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHelpTile(
            icon: Icons.upload_file_outlined,
            title: 'How to upload a suggestion?',
            description: 'Tap the + button on the home screen, fill in the details, and submit.',
          ),
          const SizedBox(height: 12),
          _buildHelpTile(
            icon: Icons.download_outlined,
            title: 'How to download materials?',
            description: 'Tap "Download" on any suggestion card. You need to be logged in.',
          ),
          const SizedBox(height: 12),
          _buildHelpTile(
            icon: Icons.search_outlined,
            title: 'How to search?',
            description: 'Use the search bar at the top to find suggestions by course name or code.',
          ),
          const SizedBox(height: 12),
          _buildHelpTile(
            icon: Icons.person_outline,
            title: 'How to edit your profile?',
            description: 'Open the side menu → Edit Profile.',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}