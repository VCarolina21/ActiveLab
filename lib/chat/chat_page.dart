import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> chats = [
    {
      "name": "Garry (CoreFit Gym)",
      "msg": "Thank you! 😄",
      "time": "7:12 Am",
      "unread": 3,
      "img": "assets/coachcowo.JPG"
    },
    {
      "name": "Jessica (MoveFit)",
      "msg": "Yes! please take a order",
      "time": "9:28 Am",
      "unread": 0,
      "img": "assets/coachcewe.JPG"
    },
    {
      "name": "Karl (ActiveFit Physiotherapy)",
      "msg": "I think this one is good",
      "time": "4:35 Pm",
      "unread": 0,
      "img": "assets/coachcowo.JPG"
    },
    {
      "name": "Sofia (FlexFit Yoga)",
      "msg": "Wow, this is really epic",
      "time": "8:12 Pm",
      "unread": 0,
      "img": "assets/coachcewe.JPG"
    },
    {
      "name": "Woody (CoreFit Gym)",
      "msg": "woohoooo",
      "time": "yesterday",
      "unread": 0,
      "img": "assets/coachcowo.JPG"
    },
        {
      "name": "Crystal (EliteFit Gym)",
      "msg": "omg, this is amazing",
      "time": "10:22 Pm",
      "unread": 0,
      "img": "assets/coachcewe.JPG"
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: chats.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFFF5F5F5),
                      indent: 85,
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return _buildChatTile(chat);
                    },
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
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage(chat['img']),
      ),
      title: Text(
        chat['name'],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          chat['msg'],
          style: const TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 8),
          if (chat['unread'] > 0)
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Color(0xFFE91E63),
                shape: BoxShape.circle,
              ),
              child: Text(
                chat['unread'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(height: 24),
        ],
      ),
    );
  }
}