import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/signup_screen.dart';

import '../Explore and account/explore_screen.dart';
import 'Forgot password/forgot_password.dart';
import 'Services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordHidden = true;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        email: email.text.trim(),
        password: password.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login successful!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to ExploreScreen and clear the back stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ExploreScreen()),
        (route) => false,
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!value.contains('@')) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: "Username or gmail",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password field with Show/Hide
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: password,
                    obscureText: _isPasswordHidden,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
                      child: Text("Forgot your password?"),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Sign in button
                SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A3DF0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
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
                            "Sign in",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have account? ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Signup Here",
                        style: TextStyle(
                          color: Color(0xFF5A3DF0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
