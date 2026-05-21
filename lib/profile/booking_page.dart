import 'package:flutter/material.dart';
import '../home/notif_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  static final Set<String> _globalCancelledKeys = {};

  void _showCancelDialog(BuildContext context, String title, String date, String month, String year, String time) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 4),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Cancel Booking?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to cancel your booking for $title?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            String cancelKey = "$title-$date-$time";
                            _globalCancelledKeys.add(cancelKey);
                            
                            NotifPage.addNotification(
                              title,
                              date,
                              month,
                              year,
                              time,
                              status: "Canceled",
                            );
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Booking for $title has been cancelled"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Yes, Cancel",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF303F9F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Back",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> displayBookings = [];
    final Set<String> uniqueKeys = {};

    for (int i = 0; i < NotifPage.notifications.length; i++) {
      final item = NotifPage.notifications[i];
      String title = item["title"] ?? "";
      String date = item["date"] ?? "";
      String time = item["time"] ?? "";
      String status = item["status"] ?? "Pending";

      if (status == "Canceled") {
        continue;
      }

      String uniqueKey = "$title-$date-$time";

      if (!uniqueKeys.contains(uniqueKey)) {
        uniqueKeys.add(uniqueKey);
        
        String finalStatus = _globalCancelledKeys.contains(uniqueKey) ? "Canceled" : "Pending";

        displayBookings.add({
          "title": title,
          "status": finalStatus,
          "data": item,
        });
      }
    }

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(76),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "My Bookings",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: displayBookings.isEmpty
                    ? const Center(
                        child: Text(
                          "You haven't booked any sessions yet.",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: displayBookings.length,
                        itemBuilder: (context, index) {
                          final bookingItem = displayBookings[index];
                          final Map<String, String> notif = bookingItem["data"] as Map<String, String>;
                          
                          String currentStatus = bookingItem["status"] as String;
                          String displayTitle = bookingItem["title"] as String;
                          
                          String branchLocation = "Jakarta";
                          String assetImage = "assets/gymuntar.jpg";

                          String titleLower = displayTitle.toLowerCase();
                          if (titleLower.contains("yoga")) {
                            branchLocation = "Jakarta";
                            assetImage = "assets/yoga.JPG";
                          } else if (titleLower.contains("hiit")) {
                            branchLocation = "Bandung";
                            assetImage = "assets/hiit.JPG";
                          } else if (titleLower.contains("pilates")) {
                            branchLocation = "Surabaya";
                            assetImage = "assets/pilates.JPG";
                          } else if (titleLower.contains("massage")) {
                            branchLocation = "Jakarta";
                            assetImage = "assets/massage.JPG";
                          } else if (titleLower.contains("spa")) {
                            branchLocation = "Jakarta";
                            assetImage = "assets/spa.JPG";
                          }

                          String dateStr = notif["date"] ?? "";
                          String monthStr = notif["month"] ?? "";
                          String yearStr = notif["year"] ?? "";
                          String timeStr = notif["time"] ?? "";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(13),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Image.asset(
                                            assetImage,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                              );
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          top: 12,
                                          left: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withAlpha(102),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.amber, size: 14),
                                                SizedBox(width: 4),
                                                Text(
                                                  "4,9",
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayTitle,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              branchLocation,
                                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                              "Dates",
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "$dateStr $monthStr $yearStr ($timeStr)",
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 100,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                color: currentStatus == "Canceled" ? Colors.redAccent : const Color(0xFFFFB300),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Text(
                                              currentStatus,
                                              style: TextStyle(
                                                color: currentStatus == "Canceled" ? Colors.redAccent : const Color(0xFFFFB300),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          if (currentStatus != "Canceled") ...[
                                            const SizedBox(height: 12),
                                            GestureDetector(
                                              onTap: () {
                                                _showCancelDialog(
                                                  context,
                                                  displayTitle,
                                                  dateStr,
                                                  monthStr,
                                                  yearStr,
                                                  timeStr,
                                                );
                                              },
                                              child: Container(
                                                width: 100,
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(15),
                                                  border: Border.all(color: Colors.redAccent, width: 1.5),
                                                ),
                                                child: const Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}