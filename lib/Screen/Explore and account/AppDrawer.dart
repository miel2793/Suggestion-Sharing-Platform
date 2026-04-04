import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/Services/auth_service.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/login_screen.dart';
import 'package:suggestion_sharing_platform/Screen/profile%20and%20dashboard/Profile.dart';
import 'package:suggestion_sharing_platform/Screen/profile%20and%20dashboard/EditProfileScreen.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/SettingsScreen.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/AboutHelpScreen.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/ReportFeedbackScreen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  String _userName = 'Guest User';
  String _userEmail = '';
  String _userDept = '';
  String _userIntake = '';
  String _userSection = '';

  static const _primaryColor = Color(0xFF42A5F5);
  static const _iconColor = Color(0xFF5F6368);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      try {
        final profile = await _authService.getProfile();
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _userName = profile['name'] ?? 'User';
            _userEmail = profile['email'] ?? '';
            _userDept = profile['dept'] ?? '';
            _userIntake = profile['intake'] ?? '';
            _userSection = profile['section'] ?? '';
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoggedIn = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // ── Drawer Header ──
            _buildDrawerHeader(),

            // ── Menu Items ──
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),

                  // ── Main Section ──
                  _buildSectionLabel('MAIN'),
                  _buildMenuItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),

                  if (_isLoggedIn) ...[
                    _buildMenuItem(
                      icon: Icons.person_rounded,
                      title: 'My Profile',
                      subtitle: 'View your profile & uploads',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const Profile()));
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.edit_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Update your information',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(
                              name: _userName,
                              dept: _userDept,
                              intake: _userIntake,
                              section: _userSection,
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 24, thickness: 0.5),
                  ),

                  // ── Support & Info Section ──
                  _buildSectionLabel('SUPPORT & INFO'),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'Password & preferences',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()));
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.support_agent_rounded,
                    title: 'Support',
                    subtitle: 'Report bugs & send feedback',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ReportFeedbackScreen()));
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'App info & contact',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AboutHelpScreen()));
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 24, thickness: 0.5),
                  ),

                  // ── Account Section ──
                  if (_isLoggedIn)
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () => _handleLogout(),
                    )
                  else
                    _buildMenuItem(
                      icon: Icons.login_rounded,
                      title: 'Login',
                      iconColor: _primaryColor,
                      textColor: _primaryColor,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()));
                      },
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Footer ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: _primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Suggest Me  •  v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── DRAWER HEADER ───────────────────
  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: _primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person_rounded,
                size: 40,
                color: _primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // User Name — always visible
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Email or login prompt
          if (_isLoggedIn && _userEmail.isNotEmpty)
            Text(
              _userEmail,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            )
          else if (!_isLoggedIn)
            Text(
              'Sign in to access more features',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),

          // Dept / Intake badge
          if (_isLoggedIn && _userDept.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_userDept  •  Intake $_userIntake  •  Sec $_userSection',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────── SECTION LABEL ───────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 8, bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ─────────────────── MENU ITEM ───────────────────
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? _iconColor).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? _iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? const Color(0xFF1F2937),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // ─────────────────── LOGOUT HANDLER ───────────────────
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent, size: 24),
            SizedBox(width: 10),
            Text('Logout',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
