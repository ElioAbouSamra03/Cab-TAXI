import 'package:cabtaxi/Controllers/RegistrationController.dart';
import 'package:cabtaxi/Routes/AppRoute.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Registration extends GetView<RegistrationController> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Manual back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Get.back(),
                ),
              ),

              const SizedBox(height: 10),

              // Registration card
              Center(
                child: Card(
                  color: Colors.black,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          label: "Full Name",
                          hint: "Enter your full name",
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: "Email",
                          hint: "Enter your email",
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: "Phone",
                          hint: "Enter your phone number",
                          icon: Icons.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: "Country",
                          hint: "Enter your country",
                          icon: Icons.flag,
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          "Password",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                            hintStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(Icons.lock, color: Colors.black),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Register",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoute.login);
                            },
                            child: const Text(
                              "Already have an account? Login here",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black),
            prefixIcon: Icon(icon, color: Colors.black),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

void setState(VoidCallback fn) {
  fn();
}
