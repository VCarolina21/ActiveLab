import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/explore_api_service.dart';
import 'mentor_detail_page.dart';

class AllStaffPage extends StatefulWidget {
  const AllStaffPage({super.key});

  @override
  State<AllStaffPage> createState() => _AllStaffPageState();
}

class _AllStaffPageState extends State<AllStaffPage> {
  List<StaffModel> _allStaff = [];
  List<StaffModel> _filteredStaff = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllStaff();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mengambil data semua staff dari API
  Future<void> _loadAllStaff() async {
    setState(() => _isLoading = true);
    try {
      final staff = await ExploreApiService.getAllStaff();
      setState(() {
        _allStaff = staff;
        _filteredStaff = staff; // Awalnya tampilkan semua
      });
    } catch (_) {
  
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterStaff(String query) {
    if (query.isEmpty) {
      setState(() => _filteredStaff = _allStaff);
    } else {
      final filtered = _allStaff.where((staff) {
        final nameLower = staff.name.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();

      setState(() {
        _filteredStaff = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9), // Background abu-abu muda
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "All Mentors",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterStaff, // Panggil filter setiap kali user mengetik
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _filterStaff(''); // Reset filter
                          },
                        )
                      : null,
                  hintText: "Cari nama mentor...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4285F4)),
                  )
                : _filteredStaff.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Tampilkan 2 kotak berdampingan
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85, // Rasio tinggi kotak
                        ),
                        itemCount: _filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = _filteredStaff[index];
                          return _buildStaffCard(staff);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffModel staff) {
    final photoUrl = staff.photoUrl;

    return GestureDetector(
      onTap: () {
        // Arahkan ke halaman Mentor Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MentorDetailPage(staff: staff),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto Profil
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF42A5F5),
                backgroundImage: photoUrl != null
                    ? CachedNetworkImageProvider(photoUrl) as ImageProvider
                    : null,
                child: photoUrl == null
                    ? Text(
                        staff.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            // Nama Staff
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                staff.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Asal Cabang / Role
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                staff.branchName, // Asumsikan model Staff punya branchName, jika tidak ganti teks bebas misal: "Mentor"
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Mentor tidak ditemukan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Coba gunakan nama lain",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}