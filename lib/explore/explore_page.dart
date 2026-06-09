import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'mentor_detail_page.dart';
import 'searching_page.dart';
import '../chat/chat_page.dart';
import '../profile/profile_page.dart';
import '../home/notif_page.dart';
import '../home/home_page.dart';
import '../scan/check_in_page.dart';
import '../scan/history_page.dart';
import '../services/booking_api_service.dart';
import '../services/explore_api_service.dart';
import '../services/branch_api_service.dart';
import '../config/app_config.dart';
import '../home/detail_page.dart';
import 'all_staff.dart';

class ExplorePage extends StatefulWidget {
  final String userName;

  const ExplorePage({super.key, required this.userName});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<BookingModel> _recentHistory = [];
  bool _isLoadingHistory = false;


  List<StaffModel> _staffList = [];
  bool _isLoadingStaff = false;

  List<BranchModel> _randomBranches = [];
  bool _isLoadingBranches = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadStaff();
    _loadRandomBranches();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await BookingApiService.getBookingHistory();
      // Ambil 3 terbaru saja
      setState(() {
        _recentHistory = history.take(3).toList();
      });
    } catch (_) {
      // Gagal load → tampilkan kosong, tidak crash
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoadingStaff = true);
    try {
      final staff = await ExploreApiService.getAllStaff();
      setState(() => _staffList = staff);
    } catch (_) {
      // Gagal → tampilkan kosong
    } finally {
      setState(() => _isLoadingStaff = false);
    }
  }


  Future<void> _loadRandomBranches() async {
    setState(() => _isLoadingBranches = true);
    try {
      // Ambil batch data cabang cukup banyak (misal limit 30) agar pengacakan bervariasi
      final res = await BranchApiService.getBranches(page: 1, limit: 30);
      final allBranches = (res['data']['branches'] as List)
          .map((b) => BranchModel.fromJson(b as Map<String, dynamic>))
          .toList();
      
      // Lakukan pengacakan susunan data (Randomize)
      allBranches.shuffle();

      setState(() {
        // Ambil maksimal 4 cabang hasil acakan tersebut
        _randomBranches = allBranches.take(4).toList();
      });
    } catch (_) {
    } finally {
      setState(() => _isLoadingBranches = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(context),
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
            if (titleLower.contains("yoga")) { assetImage = "assets/yoga.JPG"; type = "YOGA"; }
            else if (titleLower.contains("hiit")) { assetImage = "assets/hiit.JPG"; type = "HIIT"; }
            else if (titleLower.contains("pilates")) { assetImage = "assets/pilates.JPG"; type = "PILATES"; }
            else if (titleLower.contains("massage")) { assetImage = "assets/massage.JPG"; type = "MASSAGE"; }
            else if (titleLower.contains("spa")) { assetImage = "assets/spa.JPG"; type = "SPA"; }
            else if (titleLower.contains("physio") || titleLower.contains("terapi")) { assetImage = "assets/fisioterapi.JPG"; type = "PHYSIOTHERAPY"; }
            else if (titleLower.contains("gym")) { assetImage = "assets/gymuntar.jpg"; type = "GYM"; }

            int dayNum = 24;
            final RegExp matchDay = RegExp(r'^\d+');
            if (matchDay.hasMatch(date)) dayNum = int.parse(matchDay.stringMatch(date)!);
            String monthYear = date.replaceFirst(matchDay, '').trim();
            if (monthYear.contains(",")) monthYear = monthYear.split(",").first.trim();
            if (monthYear.isEmpty) monthYear = "May 2026";
            else if (!monthYear.contains("2026")) monthYear = "$monthYear 2026";
            String finalBookingRange = "$dayNum $monthYear";

            Navigator.push(context, MaterialPageRoute(
              builder: (context) => CheckInPage(
                dateString: "$date, $time", gymName: title, location: "Jakarta",
                rating: 4.9, imagePath: assetImage, bookingDates: finalBookingRange,
                guestInfo: "2 Guests (1 Room)", roomType: type,
                phoneNumber: "0214345646", status: "Pending",
              ),
            ));
          },
          backgroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.crop_free, color: Colors.black, size: 30),
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
            colors: [Color(0xFF0D47A1), Color(0xFF42A5F5), Color(0xFFB3E5FC), Colors.white],
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
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 25),
                _buildLastBooking(),
                const SizedBox(height: 25),
                _buildMentorSection(),
                const SizedBox(height: 25),
                _buildPopularGymSection(),    // ← Menampilkan 4 card cabang dinamis
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22, backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Hello !", style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            widget.userName.isNotEmpty ? widget.userName : "User",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ]),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: TextField(
        readOnly: true,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchingPage()));
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search gyms, classes, or facilities...",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildLastBooking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Last Booking",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
              },
              child: const Text("See all",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white70)),
            ),
          ],
        ),
        const SizedBox(height: 15),

        if (_isLoadingHistory)
          const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          )

        else if (_recentHistory.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "No recent booking history found.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          )

        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _recentHistory.asMap().entries.map((entry) {
                final i = entry.key;
                final booking = entry.value;
                return Padding(
                  padding: EdgeInsets.only(right: i == _recentHistory.length - 1 ? 0.0 : 15.0),
                  child: _buildBookingCardFromApi(booking),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }


  Widget _buildBookingCardFromApi(BookingModel booking) {
    final sch = booking.schedule;
    final serviceName = sch['service_name_name'] as String? ?? '';
    final branchName  = booking.branch['name'] as String? ?? '';
    final branchPhoto = booking.branch['photo'] as String?;

    // Tentukan image: pakai foto branch jika ada, fallback asset
    Widget imageWidget;
    if (branchPhoto != null && branchPhoto.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: '${AppConfig.uploadsBaseUrl}/branches/$branchPhoto',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: (_, __, ___) => Container(color: Colors.grey[400]),
      );
    } else {
      imageWidget = Container(color: const Color(0xFF42A5F5));
    }

    return Container(
      width: 160,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
              child: imageWidget,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(serviceName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(branchName,
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text("Find Your Best Mentor",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    GestureDetector(
      onTap: () {
        // Navigasi ke halaman All Staff
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllStaffPage()),
        );
      },
      child: const Text("See all",
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 14, 
            color: Color.fromARGB(255, 255, 255, 255), // Warna biru agar terlihat seperti link
          ),
      ),
    ),
  ],
),
        const SizedBox(height: 15),

        if (_isLoadingStaff)
          const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator(color: Color(0xFF4285F4), strokeWidth: 2)),
          )
        else if (_staffList.isEmpty)
          const Text("Belum ada staff tersedia", style: TextStyle(color: Colors.grey, fontSize: 13))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: _staffList.map((staff) => _buildStaffAvatar(staff)).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStaffAvatar(StaffModel staff) {
    final photoUrl = staff.photoUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MentorDetailPage(
              staff: staff,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: photoUrl != null
                  ? CachedNetworkImageProvider(photoUrl) as ImageProvider
                  : null,
                child: photoUrl == null
                  ? Text(staff.name[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey))
                  : null,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 60,
              child: Text(
                staff.name.split(' ').first, // Hanya nama depan
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularGymSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("You May Interest", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 15),
        
        if (_isLoadingBranches)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: Color(0xFF4285F4), strokeWidth: 2)),
          )
        else if (_randomBranches.isEmpty)
          const Text("Belum ada cabang tersedia", style: TextStyle(color: Colors.grey, fontSize: 13))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _randomBranches.map((branch) => _buildPopularCardFromBranch(branch)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPopularCardFromBranch(BranchModel branch) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke DetailPage dengan info cabang yang sesuai
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              branchId: branch.id,
              title: branch.name,
              location: branch.address,
              rating: 0.0,
              imagePath: branch.photoUrl ?? '',
              quota: '',
              mentorName: 'Staff',
              mentorRole: '${branch.name} Mentor',
            ),
          ),
        );
      },
      child: Container(
        width: 220, 
        height: 320,
        margin: const EdgeInsets.only(right: 15, bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              // Foto Branch dari API (Menggunakan CachedNetworkImage), fallback ke asset jika null
              branch.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: branch.photoUrl!,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[200]),
                      errorWidget: (_, __, ___) => Image.asset("assets/gymuntar.jpg", height: double.infinity, width: double.infinity, fit: BoxFit.cover),
                    )
                  : Image.asset("assets/gymuntar.jpg", height: double.infinity, width: double.infinity, fit: BoxFit.cover),
              
              // Gradasi gelap latar belakang teks (tetap dipertahankan)
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)], stops: const [0.5, 1.0]),
              ))),
              
              // Hanya menampilkan Nama Cabang dan Lokasi saja di bagian bawah card
              Positioned(
                bottom: 25, 
                left: 20, 
                right: 20, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      branch.address, 
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _navItem(context, Icons.home_filled, "Home", false, 0),
            _navItem(context, Icons.search, "Explore", true, 1),
          ]),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _navItem(context, Icons.chat_bubble_outline, "Chat", false, 2),
            _navItem(context, Icons.person_outline, "Profile", false, 3),
          ]),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool isActive, int index) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        if (isActive) return;
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(userName: widget.userName)));
        else if (index == 2) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const ChatPage())
          );
        }
        else if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage(userName: widget.userName)));
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: isActive ? const Color(0xFF4285F4) : Colors.grey),
        Text(label, style: TextStyle(fontSize: 12, color: isActive ? const Color(0xFF4285F4) : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}