import 'package:flutter/material.dart';

import 'chat_detail_page.dart';
import '../profile/profile_page.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  const ChatPage({super.key, required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> chats = [
    {
      "name": "Crystal (CoreFit Gym)",
      "msg": "Don't forget your protein intake!",
      "time": "10:15 Am",
      "unread": 1,
      "img": "assets/coachcewe.JPG",
      "locationName": "CoreFit Gym",
      "locationType": "Gym & Fitness",
      "locationImg": "assets/gymuntar.jpg",
      "messages": [
        {"text": "Hi Crystal, what should I eat after workout?", "isMe": true, "time": "10:00 AM"},
        {"text": "Don't forget your protein intake!", "isMe": false, "time": "10:15 AM"},
      ]
    },
    {
      "name": "Garry (CoreFit Gym)",
      "msg": "Thank you! 😄",
      "time": "7:12 Am",
      "unread": 0,
      "img": "assets/coachcowo.JPG",
      "locationName": "CoreFit Gym",
      "locationType": "Gym & Fitness",
      "locationImg": "assets/gymuntar.jpg",
      "messages": [
        {"text": "Hi Garry, is the weightlifting area open?", "isMe": true, "time": "7:00 AM"},
        {"text": "Yes, it is! We just added new plates.", "isMe": false, "time": "7:05 AM"},
        {"text": "Thank you! 😄", "isMe": false, "time": "7:12 AM"},
      ]
    },
    {
      "name": "Jessica (CoreFit Pilates)",
      "msg": "Yes! please take a order",
      "time": "9:28 Am",
      "unread": 0,
      "img": "assets/coachcewe.JPG",
      "locationName": "CoreFit Pilates",
      "locationType": "Pilates",
      "locationImg": "assets/pilates.JPG",
      "messages": [
        {"text": "Can I book a Pilates session?", "isMe": true, "time": "9:10 AM"},
        {"text": "Yes! please take a order.", "isMe": false, "time": "9:28 AM"},
      ]
    },
    {
      "name": "Karl (ActiveFit Physiotherapy)",
      "msg": "How is your back feeling today?",
      "time": "Yesterday",
      "unread": 2,
      "img": "assets/coachcowo.JPG",
      "locationName": "ActiveFit Physio",
      "locationType": "Physiotherapy",
      "locationImg": "assets/fisioterapi.JPG",
      "messages": [
        {"text": "The session was great, Karl.", "isMe": true, "time": "Yesterday"},
        {"text": "How is your back feeling today?", "isMe": false, "time": "Yesterday"},
      ]
    },
    {
      "name": "Sofia (FlexFit Yoga)",
      "msg": "See you at the studio, Sofia.",
      "time": "Yesterday",
      "unread": 0,
      "img": "assets/coachcewe.JPG",
      "locationName": "FlexFit Yoga",
      "locationType": "Yoga",
      "locationImg": "assets/yoga.JPG",
      "messages": [
        {"text": "Is the morning flow class still at 7?", "isMe": true, "time": "Yesterday"},
        {"text": "Yes, same schedule!", "isMe": false, "time": "Yesterday"},
        {"text": "See you at the studio, Sofia.", "isMe": true, "time": "Yesterday"},
      ]
    },
    {
      "name": "Woody (MoveFit Gym)",
      "msg": "Great progress on your deadlift!",
      "time": "Monday",
      "unread": 0,
      "img": "assets/coachcowo.JPG",
      "locationName": "MoveFit Gym",
      "locationType": "Gym & Fitness",
      "locationImg": "assets/gymuntar.jpg",
      "messages": [
        {"text": "Coach, I hit a new PR today!", "isMe": true, "time": "Monday"},
        {"text": "Great progress on your deadlift!", "isMe": false, "time": "Monday"},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {},
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Message",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildSearchBar(),
              const SizedBox(height: 25),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 100),
                    itemCount: chats.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFFF5F5F5),
                      indent: 85,
                    ),
                    itemBuilder: (context, index) => _buildChatTile(chats[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.black54),
            hintText: "Search...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              name: chat['name'],
              image: chat['img'],
              history: chat['messages'],
              locationName: chat['locationName'],
              locationType: chat['locationType'],
              locationImg: chat['locationImg'],
            ),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(chat['img']),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        chat['name'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat['msg'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chat['unread'] > 0 ? Colors.black87 : Colors.grey,
          fontWeight: chat['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat['time'],
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          if (chat['unread'] > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF4285F4),
                shape: BoxShape.circle,
              ),
              child: Text(
                chat['unread'].toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _navItem(context, Icons.home_filled, "Home", false, 0),
              _navItem(context, Icons.search, "Explore", false, 1),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _navItem(context, Icons.chat_bubble, "Chat", true, 2),
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
        if (index == 0 || index == 1) {
          Navigator.pop(context);
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(userName: widget.userName),
            ),
          );
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