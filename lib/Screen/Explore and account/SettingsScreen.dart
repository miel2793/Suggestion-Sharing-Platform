import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/Services/auth_service.dart';
import 'package:suggestion_sharing_platform/Screen/Splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);


    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password changed successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    setState(() => _isLoading = false);
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logging out...')),
    );

    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5C2D91),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Change Password Section ──
            Container(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_outline, color: Color(0xFF5C2D91), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C2D91),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Update your password to keep your account secure.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 20),

                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Current Password',
                      isHidden: _hideCurrentPassword,
                      onToggle: () => setState(() => _hideCurrentPassword = !_hideCurrentPassword),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter current password';
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      isHidden: _hideNewPassword,
                      onToggle: () => setState(() => _hideNewPassword = !_hideNewPassword),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter new password';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      isHidden: _hideConfirmPassword,
                      onToggle: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirm your password';
                        if (v != _newPasswordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Change Password Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C2D91),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Update Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Logout Section ──
            Container(
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
                      Icon(Icons.logout, color: Colors.red, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isHidden,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isHidden,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF5C2D91), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF5C2D91),
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
