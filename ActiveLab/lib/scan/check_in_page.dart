import 'package:flutter/material.dart';
import 'history_page.dart';
import 'check_out_page.dart';

class CheckInPage extends StatelessWidget {
  final String dateString;
  final String gymName;
  final String location;
  final double rating;
  final String imagePath;
  final String bookingDates;
  final String roomType;
  final String phoneNumber;
  final String status;
  final String? guestInfo;

  const CheckInPage({
    super.key,
    required this.dateString,
    required this.gymName,
    required this.location,
    required this.rating,
    required this.imagePath,
    required this.bookingDates,
    required this.roomType,
    required this.phoneNumber,
    required this.status,
    this.guestInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC),
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
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Check - in",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Bagian ini sekarang hanya berisi tombol yang diposisikan di tengah
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: _buildActionButtons(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBottomAction(context, Icons.login, "Check - In", true, () {}),
        _buildBottomAction(context, Icons.history, "History", false, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HistoryPage(),
            ),
          );
        }),
        _buildBottomAction(context, Icons.logout, "Check - Out", false, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckOutPage(
                bookingDates: bookingDates,
                roomType: roomType,
                phoneNumber: phoneNumber,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomAction(
      BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF42A5F5) : const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}