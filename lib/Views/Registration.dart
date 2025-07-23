import 'package:cabtaxi/Controllers/RegistrationController.dart';
import 'package:cabtaxi/Routes/AppRoute.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Registration extends GetView<RegistrationController>{
    
  bool _obscurePassword = true;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Registration Cab Taxi", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Register",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),

                  _buildTextField(label: "Full Name", hint: "Enter your full name", icon: Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(label: "Email", hint: "Enter your email", icon: Icons.email),
                  const SizedBox(height: 12),
                  _buildTextField(label: "Phone", hint: "Enter your phone number", icon: Icons.phone),
                  const SizedBox(height: 12),
                  _buildTextField(label: "Country", hint: "Enter your country", icon: Icons.flag),
                  const SizedBox(height: 12),

                  // Password Field with toggle icon
                  Text("Password", style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Register", style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 18),
                  Center(
                    child: TextButton(
                        onPressed: (){
                            Get.toNamed(AppRoute.login);
                        },
                         child: const Text(
                            "Already have an account? Login here",
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                         )
                        
                        ),
                  )
                ],
              ),
            ),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }


    
}

void setState(Null Function() param0) {
}