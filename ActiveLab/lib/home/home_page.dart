import 'package:flutter/material.dart';

import 'notif_page.dart';
import 'start_page.dart';
import 'detail_page.dart';
import 'weekly_target_page.dart';
import '../scan/check_in_page.dart';
import '../explore/explore_page.dart';
import '../chat/chat_page.dart';
import '../profile/profile_page.dart';
import '../services/branch_api_service.dart';
import '../config/app_config.dart';
import 'package:cached_network_image/cached_network_image.dart';


class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE UNTUK PAGINATION & API ---
  int currentPage = 1;
  final int itemsPerPage = 10;

  List<BranchModel> _branches = [];
  bool _isLoadingBranches = false;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    setState(() => _isLoadingBranches = true);
    try {
      final res = await BranchApiService.getBranches(page: currentPage, limit: itemsPerPage);
      final paginationData = res['data']['pagination'] as Map<String, dynamic>;
      setState(() {
        _branches = (res['data']['branches'] as List)
            .map((b) => BranchModel.fromJson(b as Map<String, dynamic>))
            .toList();
        _totalPages = paginationData['total_pages'] as int? ?? 1;
      });
    } catch (_) {
      // fallback: tampilkan list kosong jika terjadi error
    } finally {
      setState(() => _isLoadingBranches = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            String title = "CoreFit Spa";
            String date = "24 May";
            String time = "11:00 AM";

            if (NotifPage.notifications.isNotEmpty) {
              final firstBooking = NotifPage.notifications.first;
              title = (firstBooking["title"] ?? "CoreFit Spa").toString();
              date = (firstBooking["date"] ?? "24 May").toString();
              time = (firstBooking["time"] ?? "11:00 AM").toString();
            }

            String assetImage = "assets/spa.JPG";
            String type = "SPA";
            String titleLower = title.toLowerCase();

            if (titleLower.contains("yoga")) {
              assetImage = "assets/yoga.JPG";
              type = "YOGA";
            } else if (titleLower.contains("hiit")) {
              assetImage = "assets/hiit.JPG";
              type = "HIIT";
            } else if (titleLower.contains("pilates")) {
              assetImage = "assets/pilates.JPG";
              type = "PILATES";
            } else if (titleLower.contains("massage")) {
              assetImage = "assets/massage.JPG";
              type = "MASSAGE";
            } else if (titleLower.contains("spa")) {
              assetImage = "assets/spa.JPG";
              type = "SPA";
            } else if (titleLower.contains("physio") || titleLower.contains("terapi")) {
              assetImage = "assets/fisioterapi.JPG";
              type = "PHYSIOTHERAPY";
            } else if (titleLower.contains("gym")) {
              assetImage = "assets/gymuntar.jpg";
              type = "GYM";
            }

            int dayNum = 24;
            final RegExp matchDay = RegExp(r'^\d+');
            if (matchDay.hasMatch(date)) {
              dayNum = int.parse(matchDay.stringMatch(date)!);
            }
            
            String monthYear = date.replaceFirst(matchDay, '').trim();
            if (monthYear.contains(",")) {
              monthYear = monthYear.split(",").first.trim();
            }

            if (monthYear.isEmpty) {
              monthYear = "May 2026";
            } else if (!monthYear.contains("2026")) {
              monthYear = "$monthYear 2026";
            }
            
            String finalBookingRange = "$dayNum $monthYear";

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckInPage(
                  dateString: "$date, $time",
                  gymName: title,
                  location: "Jakarta",
                  rating: 4.9,
                  imagePath: assetImage,
                  bookingDates: finalBookingRange,
                  roomType: type,
                  phoneNumber: "0214345646",
                  status: "Pending",
                  guestInfo: "2 Guests (1 Room)",
                ),
              ),
            );
          },
          backgroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.crop_free,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF42A5F5),
              Color(0xFFB3E5FC),
              Colors.white,
            ],
            stops: [0.0, 0.25, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildHeader(context),
                const SizedBox(height: 25),
                _buildChallengeCard(),
                const SizedBox(height: 25),
                _buildWeeklyTarget(),
                const SizedBox(height: 25),
                const Text("Explore ActiveLab", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 15),
                
                // ── LOADING / DAFTAR BRANCH DARI API ──
                if (_isLoadingBranches)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Column(
                    children: _branches.map((branch) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildGymCardFromBranch(context, branch),
                      );
                    }).toList(),
                  ),

                // ── TOMBOL PAGINATION DARI API ──
                if (_totalPages > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        onPressed: currentPage > 1
                            ? () { setState(() { currentPage--; }); _fetchBranches(); }
                            : null,
                      ),
                      Text(
                        "Page $currentPage of $_totalPages",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: currentPage < _totalPages
                            ? () { setState(() { currentPage++; }); _fetchBranches(); }
                            : null,
                      ),
                    ],
                  ),
                const SizedBox(height: 100), 
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildGymCardFromBranch(BuildContext context, BranchModel branch) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailPage(
      branchId: branch.id,
      title: branch.name,
      location: branch.address,
      rating: 0.0,
      // Gunakan branch.photoUrl. Berikan fallback string kosong jika null.
      imagePath: branch.photoUrl ?? '', 
      quota: '',
      mentorName: 'Staff',
      mentorRole: '${branch.name} Mentor',
    ),
  ),
);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 80,
                child: branch.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: branch.photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(color: Colors.grey[200]),
                      errorWidget: (c, u, e) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.fitness_center, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.fitness_center, color: Colors.grey),
                    ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(branch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          branch.address,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.black)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Hello !", style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(widget.userName.isNotEmpty ? widget.userName : "User", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotifPage())),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
            child: const Icon(Icons.notifications_none_outlined, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 25, offset: const Offset(0, 12))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF64B5F6), Color(0xFF1976D2)])),
          child: Stack(children: [
            Positioned(right: -210, bottom: -45, child: Image.asset('assets/duduk.png', width: 700, fit: BoxFit.contain)),
            Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("30 Days", style: TextStyle(color: Colors.white70)),
              const Text("WHOLE BODY\nCHALLENGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 15),
              const Text("40% complete", style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 5),
              _progressBar(),
              const Text("DAY 3", style: TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.w900)),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StartPage()),
                  );
                }, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1976D2)), 
                child: const Text("START")
              ),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _progressBar() {
    return Container(width: 120, height: 8, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(5)),
      child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: 0.4, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)))));
  }

  Widget _buildWeeklyTarget() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeeklyTargetPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("WEEKLY TARGET", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15), 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: List.generate(7, (i) {
                int dayNumber = i + 1;
                return _dayCircle(dayNumber <= 3, dayNumber, dayNumber == 3);
              }),
            ),
          ]
        ),
      ),
    );
  }

  Widget _dayCircle(bool isReached, int day, bool showFire) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 35, height: 35, 
          decoration: BoxDecoration(
            shape: BoxShape.circle, 
            color: isReached ? const Color(0xFFE3F2FD) : Colors.transparent, 
            border: Border.all(color: isReached ? const Color(0xFF4285F4) : Colors.grey[300]!)
          ),
          child: Center(child: Text("$day", style: TextStyle(color: isReached ? const Color(0xFF4285F4) : Colors.grey, fontWeight: isReached ? FontWeight.bold : FontWeight.normal))),
        ),
        if (showFire)
          const Positioned(top: -12, right: -5, child: Icon(Icons.local_fire_department_rounded, color: Color(0xFF4285F4), size: 20)),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      shape: const CircularNotchedRectangle(),
      notchMargin: 12.0,
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _navItem(context, Icons.home_filled, "Home", true, 0),
              _navItem(context, Icons.search, "Explore", false, 1),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _navItem(context, Icons.chat_bubble_outline, "Chat", false, 2),
              _navItem(context, Icons.person_outline, "Profile", false, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool isActive, int index) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        if (isActive) return;
        if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExplorePage(userName: widget.userName)));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatPage(userName: widget.userName)));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage(userName: widget.userName)));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF4285F4) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF4285F4) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}