import 'package:flutter/material.dart';

import 'real_login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedGender;
  
  bool _showGenderError = false;
  bool _showNameError = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;
  bool _showPhoneError = false;

  void _validateAndContinue() {
    setState(() {
      _showNameError = _nameController.text.isEmpty;
      _showEmailError = _emailController.text.isEmpty;
      _showPasswordError = _passwordController.text.isEmpty;
      _showPhoneError = _phoneController.text.isEmpty;
      _showGenderError = _selectedGender == null;
    });

    if (!_showNameError &&
        !_showEmailError &&
        !_showPasswordError &&
        !_showPhoneError &&
        !_showGenderError) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RealLoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
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
        title: const Text(
          "Your Profile", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
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
            
            _buildTextField("Name", _nameController, _showNameError),
            _buildTextField("Email", _emailController, _showEmailError),
            _buildTextField("Password", _passwordController, _showPasswordError, isPassword: true),
            _buildTextField("Phone Number", _phoneController, _showPhoneError, isPhone: true),
            
            const SizedBox(height: 20),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Gender (Required)", 
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
            ),
            
            Row(
              children: [
                Checkbox(
                  value: _selectedGender == "Male", 
                  shape: const CircleBorder(),
                  onChanged: (v) {
                    setState(() {
                      _selectedGender = "Male";
                      _showGenderError = false;
                    });
                  }
                ), 
                const Text("Male"),
                const SizedBox(width: 20),
                Checkbox(
                  value: _selectedGender == "Female", 
                  shape: const CircleBorder(),
                  onChanged: (v) {
                    setState(() {
                      _selectedGender = "Female";
                      _showGenderError = false;
                    });
                  }
                ), 
                const Text("Female"),
              ],
            ),

            if (_showGenderError)
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    "* Please select your gender",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
            
            const SizedBox(height: 40),
            
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (_selectedGender != null && 
                           _nameController.text.isNotEmpty &&
                           _emailController.text.isNotEmpty)
                    ? [const Color(0xFF90CAF9), const Color(0xFF4285F4)]
                    : [Colors.grey.shade400, Colors.grey.shade400]
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: _validateAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)
                  ),
                ),
                child: const Text(
                  "Continue", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool showError, {bool isPassword = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            onChanged: (value) {
              if (showError && value.isNotEmpty) {
                setState(() {});
              }
            },
            decoration: InputDecoration(
              hintText: label,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), 
                borderSide: showError ? const BorderSide(color: Colors.red, width: 1) : BorderSide.none
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), 
                borderSide: showError ? const BorderSide(color: Colors.red, width: 1) : BorderSide.none
              ),
            ),
          ),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 5),
              child: Text(
                "* $label is required",
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}