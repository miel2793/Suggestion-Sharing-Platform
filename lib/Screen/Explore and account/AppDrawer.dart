import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/Services/auth_service.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/login_screen.dart';
import 'package:suggestion_sharing_platform/Screen/profile%20and%20dashboard/Profile.dart';
import 'package:suggestion_sharing_platform/Screen/profile%20and%20dashboard/EditProfileScreen.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/SettingsScreen.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/AboutHelpScreen.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/ReportFeedbackScreen.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/LeaderboardScreen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  late bool _isLoggedIn;
  late String _userName;
  late String _userEmail;
  late String _userDept;
  late String _userIntake;
  late String _userSection;
  late String _userImgUrl;

  // Professional solid color palette (matching other screens)
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _iconBgColor = Color(0xFFF3F4F6);
  static const _errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _initializeSyncData();
    _loadUserData();
  }

  /// Use static cache to instantly set initial state (prevents Guest User flicker)
  void _initializeSyncData() {
    final cachedProfile = AuthService.cachedProfile;
    final cachedStatus = AuthService.cachedIsLoggedIn;

    _isLoggedIn = cachedStatus ?? false;
    if (_isLoggedIn && cachedProfile != null) {
      _userName = cachedProfile['name'] ?? 'User';
      _userEmail = cachedProfile['email'] ?? '';
      _userDept = cachedProfile['dept'] ?? '';
      _userIntake = cachedProfile['intake'] ?? '';
      _userSection = cachedProfile['section'] ?? '';
      _userImgUrl = cachedProfile['img_url'] ?? '';
    } else {
      _userName = 'Guest User';
      _userEmail = '';
      _userDept = '';
      _userIntake = '';
      _userSection = '';
      _userImgUrl = '';
    }
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
            _userImgUrl = profile['img_url'] ?? '';
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
        color: _surfaceColor,
        child: Column(
          children: [
            // Header (solid color, no gradient)
            _buildDrawerHeader(),
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),
                  _buildSectionLabel(''),
                  _buildMenuItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Leaderboard',
                    subtitle: 'Top contributors ranking',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                      );
                    },
                  ),
                  if (_isLoggedIn) ...[
                    _buildMenuItem(
                      icon: Icons.person_rounded,
                      title: 'My Profile',
                      subtitle: 'View your profile & uploads',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Profile()),
                        );
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
                    child: Divider(height: 24, thickness: 0.5, color: _borderColor),
                  ),
                  _buildSectionLabel('SUPPORT & INFO'),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'Password & preferences',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
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
                        MaterialPageRoute(builder: (_) => const ReportFeedbackScreen()),
                      );
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
                        MaterialPageRoute(builder: (_) => const AboutHelpScreen()),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 24, thickness: 0.5, color: _borderColor),
                  ),
                  if (_isLoggedIn)
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      iconColor: _errorColor,
                      textColor: _errorColor,
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
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Footer (solid border, plain colors)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _borderColor, width: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: _primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Suggest Me  •  v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
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

  // ─────────────────── DRAWER HEADER (solid colors) ───────────────────
  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      color: _primaryColor, // solid, no gradient
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with solid white background
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _surfaceColor, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: _surfaceColor,
              backgroundImage: _userImgUrl.isNotEmpty
                  ? NetworkImage(_userImgUrl)
                  : null,
              onBackgroundImageError: _userImgUrl.isNotEmpty
                  ? (_, __) {} // ignore errors
                  : null,
              child: _userImgUrl.isEmpty
                  ? Icon(Icons.person_rounded, size: 40, color: _primaryColor)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          if (_isLoggedIn && _userEmail.isNotEmpty)
            Text(
              _userEmail,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            )
          else if (!_isLoggedIn)
            const Text(
              'Sign in to access more features',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          if (_isLoggedIn && _userDept.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '$_userDept  •  Intake $_userIntake  •  Sec $_userSection',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
      padding: const EdgeInsets.only(left: 20, top: 8, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ─────────────────── MENU ITEM (flat, modern) ───────────────────
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final effectiveIconColor = iconColor ?? _primaryColor;
    final effectiveTextColor = textColor ?? _textPrimary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: effectiveIconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: effectiveTextColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: _textSecondary,
        ),
      )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: _iconBgColor,
      splashColor: _borderColor,
    );
  }

  // ─────────────────── LOGOUT HANDLER (clean dialog) ───────────────────
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout, color: _errorColor, size: 24),
            const SizedBox(width: 10),
            const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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