import 'package:flutter/material.dart';

class NotifPage extends StatefulWidget {
  const NotifPage({super.key});

  static List<String> notifications = [
    "Your physiotherapy session starts in 30 minutes. Get ready!"
  ];

  static void addNotification(String title, String date, String month, String year, String time) {
    notifications.insert(0, "Booking Confirmed! Your $title session on $month $date, $year at $time has been successfully reserved.");
  }

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
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
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          "Notifications",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 45),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: NotifPage.notifications.isEmpty
                      ? const Center(
                          child: Text(
                            "No notifications yet",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: NotifPage.notifications.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: _buildNotifCard(NotifPage.notifications[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildNotifCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: const Color(0xFF4285F4),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}