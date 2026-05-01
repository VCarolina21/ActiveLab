import 'package:flutter/material.dart';
import 'dart:math'; 

import 'notif_page.dart';
import '../explore/explore_page.dart';
import '../chat/chat_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "All";
  final Random _random = Random();

  final List<Map<String, String>> allLocations = [
    {"name": "ActiveFit Gym", "loc": "Jakarta Utara", "type": "Gym", "img": "assets/gymuntar.jpg"},
    {"name": "ActiveFit Spa", "loc": "Jakarta Utara", "type": "Spa", "img": "assets/spa.JPG"},
    {"name": "ActiveFit Pilates", "loc": "Jakarta Utara", "type": "Pilates", "img": "assets/pilates.JPG"},
    {"name": "ActiveFit Yoga", "loc": "Jakarta Utara", "type": "Yoga", "img": "assets/yoga.JPG"},
    {"name": "ActiveFit Massage", "loc": "Jakarta Utara", "type": "Massage", "img": "assets/massage.JPG"},
    {"name": "ActiveFit Physiotherapy", "loc": "Jakarta Utara", "type": "Physiotherapy", "img": "assets/fisioterapi.JPG"},
    {"name": "ActiveFit Hiit", "loc": "Jakarta Utara", "type": "Hiit", "img": "assets/hiit.JPG"},

    {"name": "MoveFit Gym", "loc": "Jakarta Barat", "type": "Gym", "img": "assets/gymuntar.jpg"},
    {"name": "MoveFit Spa", "loc": "Jakarta Barat", "type": "Spa", "img": "assets/spa.JPG"},
    {"name": "MoveFit Pilates", "loc": "Jakarta Barat", "type": "Pilates", "img": "assets/pilates.JPG"},
    {"name": "MoveFit Yoga", "loc": "Jakarta Barat", "type": "Yoga", "img": "assets/yoga.JPG"},
    {"name": "MoveFit Massage", "loc": "Jakarta Barat", "type": "Massage", "img": "assets/massage.JPG"},
    {"name": "MoveFit Physiotherapy", "loc": "Jakarta Barat", "type": "Physiotherapy", "img": "assets/fisioterapi.JPG"},
    {"name": "MoveFit Hiit", "loc": "Jakarta Barat", "type": "Hiit", "img": "assets/hiit.JPG"},

    {"name": "FlexFit Gym", "loc": "Jakarta Pusat", "type": "Gym", "img": "assets/gymuntar.jpg"},
    {"name": "FlexFit Spa", "loc": "Jakarta Pusat", "type": "Spa", "img": "assets/spa.JPG"},
    {"name": "FlexFit Pilates", "loc": "Jakarta Pusat", "type": "Pilates", "img": "assets/pilates.JPG"},
    {"name": "FlexFit Yoga", "loc": "Jakarta Pusat", "type": "Yoga", "img": "assets/yoga.JPG"},
    {"name": "FlexFit Massage", "loc": "Jakarta Pusat", "type": "Massage", "img": "assets/massage.JPG"},
    {"name": "FlexFit Physiotherapy", "loc": "Jakarta Pusat", "type": "Physiotherapy", "img": "assets/fisioterapi.JPG"},
    {"name": "FlexFit Hiit", "loc": "Jakarta Pusat", "type": "Hiit", "img": "assets/hiit.JPG"},

    {"name": "CoreFit Gym", "loc": "Jakarta Selatan", "type": "Gym", "img": "assets/gymuntar.jpg"},
    {"name": "CoreFit Spa", "loc": "Jakarta Selatan", "type": "Spa", "img": "assets/spa.JPG"},
    {"name": "CoreFit Pilates", "loc": "Jakarta Selatan", "type": "Pilates", "img": "assets/pilates.JPG"},
    {"name": "CoreFit Yoga", "loc": "Jakarta Selatan", "type": "Yoga", "img": "assets/yoga.JPG"},
    {"name": "CoreFit Massage", "loc": "Jakarta Selatan", "type": "Massage", "img": "assets/massage.JPG"},
    {"name": "CoreFit Physiotherapy", "loc": "Jakarta Selatan", "type": "Physiotherapy", "img": "assets/fisioterapi.JPG"},
    {"name": "CoreFit Hiit", "loc": "Jakarta Selatan", "type": "Hiit", "img": "assets/hiit.JPG"},
  ];

  final List<String> categories = ["All", "Physiotherapy", "Gym", "Hiit", "Massage", "Pilates", "Spa", "Yoga"];

  @override
  void initState() {
    super.initState();
    allLocations.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredList = selectedCategory == "All"
        ? allLocations
        : allLocations.where((item) => item['type'] == selectedCategory).toList();

    return Scaffold(
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: categories.map((cat) => _buildChip(cat)).toList()),
                ),
                const SizedBox(height: 20),
                Column(
                  children: filteredList.map((data) {
                    double randomRate = 3.7 + _random.nextDouble() * 1.3;
                    int curCap = _random.nextInt(51); 
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildGymCard(
                        data['name']!, 
                        data['loc']!, 
                        randomRate.toStringAsFixed(1), 
                        "$curCap/50", 
                        data['img']!
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildChip(String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4285F4) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildGymCard(String name, String loc, String rating, String capacity, String imagePath) {
    return Container(
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
              child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.image))),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
                const SizedBox(height: 8),
                Text(capacity, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
              ],
            ),
          ),
          Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18), const SizedBox(width: 4), Text(rating, style: const TextStyle(fontWeight: FontWeight.bold))]),
        ],
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
              ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1976D2)), child: const Text("START")),
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
    int currentStreak = 3;
    return Container(
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
              return _dayCircle(dayNumber <= currentStreak, dayNumber, dayNumber == currentStreak);
            }),
          ),
        ]
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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: const Color(0xFF4285F4),
      unselectedItemColor: Colors.grey,
      onTap: (index) { 
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExplorePage(userName: widget.userName))); 
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userName: widget.userName)));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}