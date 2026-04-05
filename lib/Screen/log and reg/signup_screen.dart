import 'package:flutter/material.dart';
import 'Services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController name = TextEditingController();
  final TextEditingController department = TextEditingController();
  final TextEditingController intake = TextEditingController();
  final TextEditingController studentId = TextEditingController();
  final TextEditingController section = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  // Professional solid color palette
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _errorColor = Color(0xFFEF4444);
  static const _successColor = Color(0xFF10B981);

  @override
  void dispose() {
    name.dispose();
    department.dispose();
    intake.dispose();
    studentId.dispose();
    section.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        name: name.text.trim(),
        userId: studentId.text.trim(),
        email: email.text.trim(),
        password: password.text,
        dept: department.text.trim(),
        intake: intake.text.trim(),
        section: section.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Registration successful! Please login."),
          backgroundColor: _successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pop(context); // Go back to Login screen
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: _errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        textInputAction: TextInputAction.next,
        validator: validator,
        style: const TextStyle(fontSize: 15, color: _textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo / Header
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isTiny = MediaQuery.of(context).size.height < 650;
                      return Column(
                        children: [
                          Container(
                            width: isTiny ? 60 : 80,
                            height: isTiny ? 60 : 80,
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.person_add_alt_1,
                              color: Colors.white,
                              size: isTiny ? 32 : 42,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: isTiny ? 24 : 28,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Join the community!",
                            style: TextStyle(
                              fontSize: isTiny ? 13 : 15,
                              color: _textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 32),

                  // Form fields
                  _buildInputField(
                    controller: name,
                    hint: "Full Name",
                    validator: (v) => v!.isEmpty ? "Name required" : null,
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: department,
                    hint: "Department (e.g., CSE)",
                    validator: (v) => v!.isEmpty ? "Department required" : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: intake,
                          hint: "Intake",
                          type: TextInputType.number,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          controller: section,
                          hint: "Section",
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: studentId,
                    hint: "Student ID",
                    type: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Student ID required" : null,
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: email,
                    hint: "Email address",
                    type: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.isEmpty) return "Email required";
                      if (!v.contains('@')) return "Enter a valid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: password,
                    hint: "Password",
                    obscure: _isPasswordHidden,
                    validator: (v) {
                      if (v!.isEmpty) return "Password required";
                      if (v.length < 6) return "Minimum 6 characters";
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: _textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: confirmPassword,
                    hint: "Confirm Password",
                    obscure: _isConfirmPasswordHidden,
                    validator: (v) {
                      if (v!.isEmpty) return "Please confirm your password";
                      if (v != password.text) return "Passwords do not match";
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: _textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sign up button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _handleSignup,
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
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Already have an account? ",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}