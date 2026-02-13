import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController department = TextEditingController();
  final TextEditingController intake = TextEditingController();
  final TextEditingController studentId = TextEditingController();
  final TextEditingController section = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirm_password = TextEditingController();


  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ).copyWith(hintText: hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
     /* appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.cyan[100],
      ),*/
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // switched to Dev Branch

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
                    obscure: true,
                    validator: (v) {
                      if (v!.isEmpty) return "Password required";
                      if (v.length < 6) {
                        return "Minimum 6 characters";
                      }
                      return null;
                    },
                  ),
                 const SizedBox(height: 15),

                  _inputBox(
                    controller: confirm_password,
                    hint: "Confirm Password",
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Confirm password is required";
                      if (v != password.text) return "Passwords do not match";
                      return null;
                    },
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          debugPrint("Signup Successful");
                        }
                      },
                      child: const Text(
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
