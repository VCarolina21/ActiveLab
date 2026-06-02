import 'package:flutter/material.dart';
// PENTING 1: Pastikan path import ini sesuai dengan lokasi file api_service.dart kamu!
import '../services/api_service.dart'; 
// PENTING 2: Pastikan path import ini sesuai dengan halaman Home/Landing kamu!
import '../home/home_page.dart'; 

class RealLoginPage extends StatefulWidget {
  const RealLoginPage({super.key});

  @override
  State<RealLoginPage> createState() => _RealLoginPageState();
}

class _RealLoginPageState extends State<RealLoginPage> {
  // Controller untuk menangkap teks yang diketik user
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool isLoading = false; // Untuk animasi loading saat nunggu balasan dari server

  // FUNGSI UTAMA PENGECEKAN LOGIN
  void _handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Cegah user klik kalau form masih kosong
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Nyalakan loading
    setState(() {
      isLoading = true;
    });

    // TEMBAK KE BACKEND! (Memanggil api_service.dart)
    bool isSuccess = await ApiService.login(email, password);

    // Matikan loading setelah backend membalas
    setState(() {
      isLoading = false;
    });

    // Pengecekan hasil
    if (isSuccess) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Berhasil! 🎉'), backgroundColor: Colors.green),
      );
      
      // Pindah ke halaman Home (Ganti HomePage() dengan nama class halaman utamamu)
      Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => HomePage(userName: ApiService.currentUserName ?? 'Member'),
  ), 
);
    } else {
      if (!mounted) return;
      // Kalau gagal, cegah masuk dan beri peringatan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Gagal! Email tidak terdaftar atau Password salah.'), 
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A90E2), // Sesuaikan dengan warna biru ActiveLab kamu
      body: SafeArea(
        child: Column(
          children: [
            // Bagian atas (Bisa disesuaikan kalau kamu pakai gambar logo khusus)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "A  L",
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      "ACTIVE LAB",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "PHYSIOTHERAPY & PAIN MANAGEMENT",
                      style: TextStyle(fontSize: 10, color: Colors.black54, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bagian bawah (Card putih tempat form login)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // INPUT EMAIL
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email', // Aku ubah jadi Email biar nggak salah masukin Nama
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // INPUT PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: true, // Biar passwordnya jadi titik-titik
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // TOMBOL LOGIN
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin, // Kalau lagi loading, tombol dimatikan
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text("Next", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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
}