import 'package:flutter/material.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Daftar 6 Mentor Lengkap
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Message",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
}