import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text("Your Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 60, color: Colors.black),
            ),
            const SizedBox(height: 30),
            // Input Fields
            _buildTextField("Name"),
            _buildTextField("Email"),
            _buildTextField("Password", isPassword: true),
            _buildTextField("Phone Number"),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Gender (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                Checkbox(value: false, onChanged: (v) {}), const Text("Male"),
                const SizedBox(width: 20),
                Checkbox(value: false, onChanged: (v) {}), const Text("Female"),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text("Skip", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF90CAF9), Color(0xFF4285F4)]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("Continue", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}