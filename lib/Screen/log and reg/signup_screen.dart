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

  bool _isLoading = false;
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    name.dispose();
    department.dispose();
    intake.dispose();
    studentId.dispose();
    section.dispose();
    email.dispose();
    password.dispose();
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
        const SnackBar(
          content: Text("Registration successful! Please login."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Go back to Login screen
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _inputBox(
                    controller: name,
                    hint: "Full Name",
                    validator: (v) =>
                        v!.isEmpty ? "Name required" : null,
                  ),

                  const SizedBox(height: 15),

                  _inputBox(
                    controller: department,
                    hint: "Department",
                    validator: (v) =>
                        v!.isEmpty ? "Department required" : null,
                  ),

                  const SizedBox(height: 15),

                  _inputBox(
                    controller: intake,
                    hint: "Intake",
                    type: TextInputType.number,
                    validator: (v) =>
                        v!.isEmpty ? "Intake required" : null,
                  ),

                  const SizedBox(height: 15),

                  _inputBox(
                    controller: studentId,
                    hint: "Student ID",
                    type: TextInputType.number,
                    validator: (v) =>
                        v!.isEmpty ? "ID required" : null,
                  ),

                  const SizedBox(height: 15),

                  _inputBox(
                    controller: section,
                    hint: "Section",
                    validator: (v) =>
                        v!.isEmpty ? "Section required" : null,
                  ),

                  const SizedBox(height: 15),

                  _inputBox(
                    controller: email,
                    hint: "Email",
                    type: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.isEmpty) return "Email required";
                      if (!v.contains('@')) return "Invalid email";
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  _inputBox(
                    controller: password,
                    hint: "Password",
                    obscure: _isPasswordHidden,
                    validator: (v) {
                      if (v!.isEmpty) return "Password required";
                      if (v.length < 6) {
                        return "Minimum 6 characters";
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: 180,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A3DF0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
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
                              "Sign up",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFF5A3DF0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}