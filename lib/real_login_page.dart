import 'package:flutter/material.dart';

class RealLoginPage extends StatelessWidget {
  const RealLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF90CAF9), Color(0xFF4285F4)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Tombol Back
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const Text(
              "A   L\nACTIVE LAB",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 5),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const Text("Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  _buildInput("Name"),
                  const SizedBox(height: 15),
                  _buildInput("Password", isPassword: true),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF90CAF9), Color(0xFF4285F4)]),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}