import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../config/services/user_api_services.dart';
import '../config/services/user_session.dart';
import '../config/app_config.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // --- DATA DUMMY ---
  final TextEditingController _nameController = TextEditingController(
    text: "sd",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "081234567890",
  );
  String _selectedGender = "Female";
  File? _pickedImage;
  String? _currentPhotoUrl;
  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _genderOptions = ["Male", "Female", "Other"];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final userData = await UserSession.getUserData();
    setState(() {
      _nameController.text = userData['name'] as String? ?? '';
      _phoneController.text = userData['phone'] as String? ?? '';
      _selectedGender = (userData['gender'] as String?)?.isNotEmpty == true
          ? userData['gender'] as String
          : 'Male';
      _currentPhotoUrl = AppConfig.buildUserPhotoUrl(
        userData['photo'] as String?,
      );
    });
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery, // buka galeri
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    try {
                      final response = await UserApiService.updateProfile(
                        name: _nameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        gender: _selectedGender,
                        photoFile: _pickedImage,
                      );

                      final updatedUser =
                          response['data'] as Map<String, dynamic>;

                      // Update session dengan data terbaru
                      await UserSession.updateUserData(
                        name: updatedUser['name'] as String?,
                        phone: updatedUser['phone'] as String?,
                        gender: updatedUser['gender'] as String?,
                        photo: updatedUser['photo'] as String?,
                      );

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() => _isLoading = false);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            child: const Text(
              "Save",
              style: TextStyle(
                color: Color(
                  0xFF4285F4,
                ), // Mengikuti warna biru tema aplikasi Anda
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // --- EDIT GAMBAR PROFIL ---
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!) as ImageProvider
                      : (_currentPhotoUrl != null &&
                            _currentPhotoUrl!.isNotEmpty)
                      ? NetworkImage(_currentPhotoUrl!) as ImageProvider
                      : const AssetImage('assets/profile.JPG'),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- EDIT NAMA ---
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- EDIT NOMOR TELEPON ---
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- EDIT GENDER ---
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: "Gender",
                prefixIcon: const Icon(Icons.transgender),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
