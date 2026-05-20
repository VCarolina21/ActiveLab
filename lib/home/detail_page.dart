import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notif_page.dart';

class ChatMentorPage extends StatefulWidget {
  final String mentorName;
  final String mentorRole;

  const ChatMentorPage({
    super.key,
    required this.mentorName,
    required this.mentorRole,
  });

  @override
  State<ChatMentorPage> createState() => _ChatMentorPageState();
}

class _ChatMentorPageState extends State<ChatMentorPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add({
      "text": "Halo! Ada yang bisa saya bantu terkait program ${widget.mentorRole} hari ini?",
      "isMe": false,
      "time": DateFormat('hh:mm a').format(DateTime.now()),
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "text": _messageController.text.trim(),
        "isMe": true,
        "time": DateFormat('hh:mm a').format(DateTime.now()),
      });
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF4285F4),
              child: Text(
                widget.mentorName[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mentorName,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.mentorRole,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg["isMe"] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg["isMe"] ? const Color(0xFF4285F4) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(msg["isMe"] ? 16 : 0),
                        bottomRight: Radius.circular(msg["isMe"] ? 0 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: msg["isMe"] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg["text"],
                          style: TextStyle(
                            color: msg["isMe"] ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg["time"],
                          style: TextStyle(
                            color: msg["isMe"] ? Colors.white70 : Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xE0E0E0E0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF4285F4),
                      radius: 22,
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final String title;
  final String location;
  final double rating;
  final String imagePath;
  final String quota;
  final String mentorName;
  final String mentorRole;

  const DetailPage({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.imagePath,
    required this.quota,
    required this.mentorName,
    required this.mentorRole,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int selectedDateIndex = 0;
  int selectedTimeIndex = -1;
  bool isBooked = false;

  late List<Map<String, String>> dates;
  late List<String> times;

  @override
  void initState() {
    super.initState();
    _generateDynamicDates();
    _generateDynamicTimes();
  }

  void _generateDynamicDates() {
    dates = List.generate(7, (index) {
      DateTime date = DateTime.now().add(Duration(days: index));
      List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      return {
        "day": days[date.weekday - 1],
        "date": date.day.toString(),
      };
    });
  }

  void _generateDynamicTimes() {
    times = [];
    for (int hour = 10; hour <= 22; hour++) {
      DateTime tempDate = DateTime(2026, 1, 1, hour);
      times.add(DateFormat('hh:00 a').format(tempDate));
    }
  }

  void _handleBooking() {
    final selectedData = dates[selectedDateIndex];
    final now = DateTime.now();
    final year = now.year.toString();
    const List<String> months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    final monthName = months[now.month - 1];

    NotifPage.addNotification(
      widget.title, 
      selectedData["date"]!, 
      monthName, 
      year, 
      times[selectedTimeIndex]
    );

    setState(() {
      isBooked = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isBooked) {
      return _buildSuccessView();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 350,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(widget.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                                child: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                            ),
                            Text(
                              "Detail ${widget.title.split(' ').last}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  transform: Matrix4.translationValues(0, -30, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.blue, size: 18),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.location,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 15),
                                  const Icon(Icons.star, color: Colors.orange, size: 18),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.rating.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatMentorPage(
                                    mentorName: widget.mentorName,
                                    mentorRole: widget.mentorRole,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chat_bubble_outline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Facilities",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFacilityItem(Icons.air, "Physiotherapy"),
                          _buildFacilityItem(Icons.self_improvement, "Yoga"),
                          _buildFacilityItem(Icons.waves, "Sauna"),
                          _buildFacilityItem(Icons.groups, "Counseling"),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Description",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "ActiveLab ${widget.location} branch provides premium services, spacious areas, and the best facilities to help you achieve your physical goals. Current quota: ${widget.quota}.",
                        style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 14),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Select Date",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: dates.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedDateIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => selectedDateIndex = index),
                              child: Container(
                                width: 60,
                                margin: const EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF4285F4) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dates[index]["day"]!,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white70 : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      dates[index]["date"]!,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Select Time",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(times.length, (index) {
                          bool isSelected = selectedTimeIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => setState(() => selectedTimeIndex = index)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF4285F4) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF4285F4) : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                times[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Location",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/map.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: selectedTimeIndex != -1 
                      ? [const Color(0xFF64B5F6), const Color(0xFF2196F3)]
                      : [Colors.grey[400]!, Colors.grey[400]!],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  onPressed: selectedTimeIndex != -1 ? _handleBooking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "BOOK NOW",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSuccessView() {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => setState(() => isBooked = false),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Booking Completed",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Your transaction was successful. Enjoy your premium access to ActiveLab Gym and get ready for ${widget.title}!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blueGrey),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}