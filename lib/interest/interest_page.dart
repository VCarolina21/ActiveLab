import 'package:flutter/material.dart';
import '../home/home_page.dart'; 
import '../services/api_service.dart'; // PENTING: Pastikan path ini benar!

class InterestPage extends StatefulWidget {
  final String userName; 
  final String email; // Tambahan wadah untuk menerima email dari halaman Register

  const InterestPage({super.key, required this.userName, required this.email});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  final List<String> _interests = [
    "Spa", "Strength Training", "Hiit", "Pilates", "Plunge Pool", 
    "Gym", "Cardio", "Calisthenics", "Physiotherapy", "Personal Training"
  ];

  final Set<String> _selectedInterests = {};
  bool _showError = false;
  bool _isLoading = false; // Untuk animasi loading saat menyimpan

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(color: Color(0xFF81C784), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 45),
                ),
                const SizedBox(height: 20),
                const Text("Success", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  "Your Account is successfully\ncreated and preferences saved!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF90CAF9), Color(0xFF4285F4)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage(userName: widget.userName)),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // FUNGSI UNTUK MENYIMPAN KE DATABASE
  void _saveInterests() async {
    if (_selectedInterests.length < 3) {
      setState(() => _showError = true);
      return;
    }

    setState(() => _isLoading = true);

    // KEAJAIBAN TERJADI DI SINI: Mengubah Set klik-klikan menjadi 1 teks panjang
    String interestsText = _selectedInterests.join(', ');

    // Kirim teks tersebut ke Supabase lewat backend
    bool isSuccess = await ApiService.updateInterests(widget.email, interestsText);

    setState(() => _isLoading = false);

    if (isSuccess) {
      _showSuccessDialog(); // Kalau berhasil simpan, baru munculkan pop-up
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan preferensi. Cek koneksi server.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSelectionValid = _selectedInterests.length >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const Text("Choose Your Interest", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  const Text(
                    "Tell us what brings you to ActiveLab. We'll tailor the best classes and recovery sessions just for you.",
                    style: TextStyle(color: Colors.black54, fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 35),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _interests.map((interest) {
                      final bool isSelected = _selectedInterests.contains(interest);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedInterests.remove(interest);
                            } else {
                              _selectedInterests.add(interest);
                            }
                            if (_selectedInterests.length >= 3) {
                              _showError = false;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4285F4) : Colors.black12,
                              width: 1.5,
                            ),
                            boxShadow: isSelected 
                              ? [BoxShadow(color: const Color(0xFF4285F4).withValues(alpha: 0.1), blurRadius: 8)]
                              : [],
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF4285F4) : Colors.black54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  if (_showError)
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 16),
                        SizedBox(width: 5),
                        Text(
                          "Please select at least 3 interests to continue",
                          style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelectionValid
                              ? [const Color(0xFF90CAF9), const Color(0xFF4285F4)]
                              : [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveInterests, // Panggil fungsi simpan
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            Positioned(
              top: 10,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}