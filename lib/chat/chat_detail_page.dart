import 'package:flutter/material.dart';

class ChatDetailPage extends StatelessWidget {
  final String name, image, locationName, locationType, locationImg;
  final List<dynamic> history;

  const ChatDetailPage({
    super.key, required this.name, required this.image, required this.history,
    required this.locationName, required this.locationType, required this.locationImg,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          CircleAvatar(backgroundImage: AssetImage(image)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
            const Text("Online", style: TextStyle(color: Colors.blue, fontSize: 11)),
          ]),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: history.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return Column(children: [_buildProductCard(), const SizedBox(height: 25)]);
                final chat = history[index - 1];
                return _buildChatBubble(chat['text'], chat['isMe'], chat['time']);
              },
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.asset(locationImg, width: 70, height: 70, fit: BoxFit.cover)),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(locationName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(locationType, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Text("Rp 25.000 /Hour", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ])),
        const Icon(Icons.star, color: Colors.amber, size: 18),
        const Text(" 5", style: TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildChatBubble(String msg, bool isMe, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF0066FF) : Colors.white,
              borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(isMe ? 20 : 0), bottomRight: Radius.circular(isMe ? 0 : 20)),
            ),
            child: Text(msg, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(20), color: Colors.white,
      child: Row(children: [
        Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(30)), child: const TextField(decoration: InputDecoration(hintText: "Write ...", border: InputBorder.none)))),
        const SizedBox(width: 10),
        const CircleAvatar(backgroundColor: Color(0xFF0066FF), child: Icon(Icons.send, color: Colors.white, size: 20)),
      ]),
    );
  }
}