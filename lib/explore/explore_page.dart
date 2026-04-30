import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  final String userName;

  const ExplorePage({super.key, required this.userName});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Colors.white],
            stops: [0.0, 0.4],
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
                _buildPopularGymSection(),
                const SizedBox(height: 20),
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
          radius: 22,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hello !", style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
            Text(
              widget.userName.isNotEmpty ? widget.userName : "User", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
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

  Widget _buildLastBooking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              _buildBookingCard("GYM 1", "50 %", "assets/gymuntar.jpg"),
              const SizedBox(width: 15),
              _buildBookingCard("GYM 2", "50 %", "assets/gymuntar.jpg"),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
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

  Widget _buildMentorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Find Your Best Mentor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _buildMentorAvatar("Crystal", "assets/coachcewe.JPG"),
                _buildMentorAvatar("Garry", "assets/coachcowo.JPG"),
                _buildMentorAvatar("Jessica", "assets/coachcewe.JPG"),
                _buildMentorAvatar("Karl", "assets/coachcowo.JPG"),
                _buildMentorAvatar("Sofia", "assets/coachcewe.JPG"),
                _buildMentorAvatar("Woody", "assets/coachcowo.JPG"),
              ],
            ),
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 30, 
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(imagePath)
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPopularGymSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Most Popular At GYM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPopularCard("GYM", "CoreFit Gym", "Jakarta Selatan", "assets/gymuntar.jpg", "6:00 PM", "180", "Garry"),
              _buildPopularCard("PILATES", "MoveFit Pilates", "Jakarta Barat", "assets/pilates.JPG", "7:00 PM", "120", "Jessica"),
              _buildPopularCard("YOGA", "FlexFit Yoga", "Jakarta Pusat", "assets/yoga.JPG", "7:00 PM", "90", "Sofia"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularCard(String category, String name, String loc, String imagePath, String time, String duration, String coach) {
    return Container(
      width: 220, 
      height: 320, 
      margin: const EdgeInsets.only(right: 15, bottom: 15), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                  Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 5),
                  Text("$name, $loc", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$time | $duration\nMins", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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