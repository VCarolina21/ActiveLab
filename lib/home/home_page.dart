import 'package:flutter/material.dart';

import 'notif_page.dart';
import '../explore/explore_page.dart';

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

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
              _buildHeader(context),
              const SizedBox(height: 25),
              _buildChallengeCard(),
              const SizedBox(height: 25),
              _buildWeeklyTarget(),
              const SizedBox(height: 25),
              _buildExploreSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFFE0E0E0),
          child: Icon(Icons.person, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hello !", style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text(
              userName.isNotEmpty ? userName : "User", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotifPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1), 
                  blurRadius: 4,
                )
              ],
            ),
            child: const Icon(Icons.notifications_none_outlined, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF90CAF9), Color(0xFF4285F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("30 Days", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const Text("WHOLE BODY\nCHALLENGE", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 15),
              Container(
                width: 120,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3), 
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text("40% complete", style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 10),
              const Text("DAY 3", style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4285F4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(140, 40),
                ),
                child: const Text("START", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Positioned(
            right: -10,
            bottom: 0,
            child: Icon(
              Icons.fitness_center, 
              size: 150, 
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTarget() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("WEEKLY TARGET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              IconButton(icon: const Icon(Icons.ios_share, size: 18), onPressed: () {}),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              bool isSelected = index == 0;
              return Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? const Color(0xFF4285F4) : Colors.transparent),
                ),
                child: Center(
                  child: Text(
                    "${index + 1}", 
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF4285F4) : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreSection() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Explore ActiveLab", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("View all", style: TextStyle(color: Color(0xFF4285F4), fontSize: 14)),
          ],
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip("All", isSelected: true),
              _buildChip("Breathing exercise"),
              _buildChip("Physical"),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildGymCard("GYM 1", "Jakarta", "5,0", "60/60", "assets/gymuntar.heic"),
        const SizedBox(height: 20),
        _buildGymCard("GYM 2", "Bali", "3,8", "40/100", "assets/gymuntar.heic"),
        const SizedBox(height: 20),
        _buildGymCard("GYM 3", "Puncak", "4,5", "20/50", "assets/gymuntar.heic"),
      ],
    );
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4285F4) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black54)),
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
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 5,
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
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(capacity, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, 
      selectedItemColor: const Color(0xFF4285F4),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExplorePage()),
          );
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