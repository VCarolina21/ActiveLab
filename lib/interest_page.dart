import 'package:flutter/material.dart';

class InterestPage extends StatefulWidget {
  const InterestPage({super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  final List<String> _interests = [
    "Spa", "Strength Training", "Pilates", 
    "Plunge Pool", "Cardio", "Physiotherapy", "Personal Training"
  ];

  final Set<String> _selectedInterests = {};
  bool _showError = false;

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF81C784),
                  child: Icon(Icons.check, color: Colors.white, size: 45),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Success",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your Account is successfully\ncreated",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF90CAF9), Color(0xFF4285F4)]
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Tutup dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text("Continue", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose Your Interest",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Tell us what brings you to ActiveLab. We'll tailor the best classes and recovery sessions just for you.",
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 30),
            
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _interests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(interest);
                      } else {
                        _selectedInterests.add(interest);
                      }
                      if (_selectedInterests.length >= 3) _showError = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4285F4) : Colors.black12,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1976D2) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            if (_showError)
              const Text(
                "* Please select at least 3 interests to continue",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _selectedInterests.length >= 3 
                        ? [const Color(0xFF90CAF9), const Color(0xFF4285F4)]
                        : [Colors.grey.shade300, Colors.grey.shade400]
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedInterests.length < 3) {
                      setState(() => _showError = true);
                    } else {
                      _showSuccessDialog(); // Tampilkan Pop-up
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}