import 'dart:ui';
import 'package:activelab/schedule/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notif_page.dart';

// --- IMPORT ---
import '../services/branch_api_service.dart';
import '../membership/membership_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../schedule/schedule_page.dart';

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mentorName,
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.mentorRole,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
  final int? branchId;
  final String title;
  final String location;
  final double rating;
  final String imagePath;
  final String quota;
  final String mentorName;
  final String mentorRole;

  const DetailPage({
    super.key,
    this.branchId,
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
  List<MembershipModel> _memberships = [];
  List<ServiceTypeModel> _serviceTypes = []; // Tambah variabel state service types
  String _branchAddress = '';
  String? _branchPhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _branchAddress = widget.location;
    if (widget.branchId != null) _fetchBranchDetail();
  }

  Future<void> _fetchBranchDetail() async {
    setState(() => _isLoading = true);
    try {
      final res = await BranchApiService.getBranchDetail(widget.branchId!);
      final branchData    = res['data']['branch'] as Map<String, dynamic>;
      final membershipData = res['data']['memberships'] as List<dynamic>;
      final serviceTypeData = res['data']['service_types'] as List<dynamic>? ?? []; // Parsing service_types

      setState(() {
        _branchAddress = branchData['address'] as String? ?? widget.location;
        final photo = branchData['photo'] as String?;
        if (photo != null) {
          _branchPhotoUrl = '${AppConfig.uploadsBaseUrl}/branches/$photo';
        }
        _memberships = membershipData
            .map((m) => MembershipModel.fromJson(m as Map<String, dynamic>))
            .toList();
        _serviceTypes = serviceTypeData
            .map((t) => ServiceTypeModel.fromJson(t as Map<String, dynamic>))
            .toList(); // Simpan hasil map ke variabel state
      });
    } catch (_) {
      // Fallback
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String activeImage = (_branchPhotoUrl != null && _branchPhotoUrl!.isNotEmpty)
        ? _branchPhotoUrl!
        : widget.imagePath;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: activeImage.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: activeImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : Image.asset(
                          activeImage.isNotEmpty ? activeImage : 'assets/placeholder_image.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Detail Cabang",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.blue, size: 18),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    widget.location,
                                    style: const TextStyle(color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
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
                  const Text("Booking Service", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  // Update bagian Booking Service dengan data dinamis dari _serviceTypes
                  _serviceTypes.isEmpty
                      ? const Text("Belum ada layanan tersedia", style: TextStyle(color: Colors.grey))
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _serviceTypes.map((type) => _buildServiceTypeItem(type)).toList(),
                        ),
                  const SizedBox(height: 30),
                  const Text("Membership", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _memberships.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text("Belum ada paket membership", style: TextStyle(color: Colors.grey)),
                            )
                          : Column(
                              children: _memberships.map((m) => _buildMembershipCard(m)).toList(),
                            ),
                  const SizedBox(height: 30),
                  const Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueGrey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _branchAddress.isNotEmpty ? _branchAddress : widget.location,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ganti _buildFacilityItem dengan _buildServiceTypeItem dinamis
  Widget _buildServiceTypeItem(ServiceTypeModel type) {
    return GestureDetector(
      onTap: () {
        if (widget.branchId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchedulePage(
                branchId: widget.branchId!,
                branchName: widget.title,
                branchAddress: _branchAddress,
                serviceType: type,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          type.name,
          style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMembershipCard(MembershipModel m) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return GestureDetector(
      onTap: () {
        if (widget.branchId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MembershipDetailPage(
                membership: m,
                branchId: widget.branchId!,
                branchName: widget.title,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Lv ${m.level}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    "${m.activeDays} hari",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              formatter.format(m.price),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF4285F4),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}