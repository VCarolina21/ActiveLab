import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/explore_api_service.dart';

class MentorDetailPage extends StatelessWidget {
  final StaffModel staff;

  const MentorDetailPage({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = staff.photoUrl;


    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D47A1), Color(0xFF42A5F5), Color(0xFFB3E5FC), Colors.white],
                stops: [0.0, 0.25, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        Text(
                          staff.name,
                          style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          alignment: Alignment.topCenter,
                          placeholder: (_, __) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(staff.name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        )
                      // Fallback: inisial nama
                      : Container(
                          color: const Color(0xFF42A5F5),
                          child: Center(
                            child: Text(staff.name[0].toUpperCase(),
                              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                  ),
                  const SizedBox(height: 11),
                ],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.43,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatCard(staff.branchName, "Cabang"),
                const SizedBox(width: 20),
                _buildStatCard(staff.contact ?? "-", "No. Telepon"),
              ],
            ),
          ),


          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text("About", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        staff.description?.isNotEmpty == true
                          ? staff.description!
                          : "Belum ada deskripsi tersedia.",
                        style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tombol Chat (TIDAK BERUBAH)
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(colors: [Color(0xFF81D4FA), Color(0xFF42A5F5)]),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Chat",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 140, height: 95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}