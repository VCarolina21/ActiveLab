import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
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
              _buildPopularGymSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header
  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFE0E0E0),
          child: Icon(Icons.person, color: Colors.black),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hallo !", style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text("Budi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        const Spacer(),
        const Icon(Icons.notifications_none_outlined, color: Colors.black, size: 28),
      ],
    );
  }

  // 2. Search Bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: "What's your goal today?",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  // 3. Last Booking Section (Ukuran Teks & Persen Diperbesar)
  Widget _buildLastBooking() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Last Booking", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextButton(
              onPressed: () {},
              child: const Text("See All", style: TextStyle(color: Color(0xFF4285F4))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildBookingCard("GYM 1", "50 %", "assets/gymuntar.heic"),
              const SizedBox(width: 15),
              _buildBookingCard("GYM 2", "50 %", "assets/gymuntar.heic"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(String name, String progress, String imagePath) {
    return Container(
      width: 150, 
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                name,
                style: const TextStyle(
                  color: Color(0xFFF5F5F5), 
                  fontWeight: FontWeight.bold,
                  fontSize: 18, 
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Container(
                width: 55, 
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4FC3F7), 
                    width: 4, 
                  ),
                ),
                child: Center(
                  child: Text(
                    progress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, 
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Mentor Section
  Widget _buildMentorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Find Your Best Mentor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMentorAvatar("Apes", "assets/coachcowo.JPG"),
              _buildMentorAvatar("John", "assets/coachcewe.JPG"),
              _buildMentorAvatar("Rudy", "assets/coachcowo.JPG"),
              _buildMentorAvatar("Kucing", "assets/coachcewe.JPG"),
              _buildMentorAvatar("imut", "assets/coachcowo.JPG"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMentorAvatar(String name, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundImage: AssetImage(imagePath)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 5. Most Popular Gym Section (Vertikal Lonjong dengan Shadow & Teks di Depan)
  Widget _buildPopularGymSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Most Popular GYM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextButton(
              onPressed: () {},
              child: const Text("See All", style: TextStyle(color: Color(0xFF4285F4))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPopularCard("GYM 1", "Jakarta", "assets/gymuntar.heic", "6:00 PM", "Jhon"),
              _buildPopularCard("GYM 2", "Jakarta", "assets/gymuntar.heic", "7:00 PM", "Jhon"),
              _buildPopularCard("GYM 3", "Jakarta", "assets/gymuntar.heic", "7:00 PM", "Jhon"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularCard(String name, String loc, String imagePath, String time, String coach) {
    return Container(
      width: 220, 
      height: 320, 
      margin: const EdgeInsets.only(right: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            Image.asset(imagePath, height: double.infinity, width: double.infinity, fit: BoxFit.cover),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SPA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 5),
                  Text("$name, $loc", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$time | 60\nMins", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(coach, style: const TextStyle(color: Colors.white, fontSize: 14)),
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

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      selectedItemColor: const Color(0xFF4285F4),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) Navigator.pop(context);
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