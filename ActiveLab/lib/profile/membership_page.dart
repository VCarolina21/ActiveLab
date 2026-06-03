import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/membership_api_service.dart';
import '../payment/payment_page.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  List<UserMembershipModel> _memberships = [];
  bool _isLoading = true;
  String? _errorMsg;

  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  Future<void> _loadMemberships() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final data = await MembershipApiService.getUserMemberships();
      setState(() { _memberships = data; });
    } catch (e) {
      setState(() { _errorMsg = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFreeze(UserMembershipModel um) async {
    try {
      if (um.isFrozen) {
        await MembershipApiService.unfreeze(um.id);
        _showSnack("Membership aktif kembali");
      } else {
        await MembershipApiService.freeze(um.id);
        _showSnack("Membership di-freeze");
      }
      _loadMemberships();
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  void _showUpgradeSheet(UserMembershipModel um) async {
    final options = await MembershipApiService.getUpgradeOptions(um.id);
    if (!mounted) return;
    if (options.isEmpty) {
      _showSnack("Tidak ada opsi upgrade tersedia", isError: true);
      return;
    }
    _showMembershipOptionsSheet(
      title: "Pilih Upgrade Membership",
      options: options,
      onSelect: (selectedId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              membershipId: selectedId,
              transactionType: 'upgrade',
              userMembershipId: um.id,
            ),
          ),
        ).then((_) => _loadMemberships());
      },
    );
  }

  void _showDowngradeSheet(UserMembershipModel um) async {
    final options = await MembershipApiService.getDowngradeOptions(um.id);
    if (!mounted) return;
    if (options.isEmpty) {
      _showSnack("Tidak ada opsi downgrade tersedia", isError: true);
      return;
    }
    _showMembershipOptionsSheet(
      title: "Pilih Downgrade Membership",
      options: options,
      onSelect: (selectedId) async {
        try {
          await MembershipApiService.downgrade(um.id, selectedId);
          _showSnack("Membership berhasil di-downgrade");
          _loadMemberships();
        } catch (e) {
          _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
        }
      },
    );
  }

  void _showMembershipOptionsSheet({
    required String title,
    required List<Map<String, dynamic>> options,
    required void Function(int selectedId) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ...options.map((opt) {
              final price = double.tryParse(opt['price'].toString()) ?? 0;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onSelect(opt['id'] as int);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Lv ${opt['level']}",
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      Text(
                        formatter.format(price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Memberships",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadMemberships,
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4285F4)))
        : _errorMsg != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMsg!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  ElevatedButton(onPressed: _loadMemberships, child: const Text("Coba Lagi")),
                ],
              ),
            )
          : _memberships.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_membership, size: 60, color: Colors.grey),
                    SizedBox(height: 15),
                    Text("Belum ada membership aktif", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    SizedBox(height: 8),
                    Text("Beli membership dari halaman Explore", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _memberships.length,
                itemBuilder: (_, i) => _buildMembershipCard(_memberships[i]),
              ),
    );
  }

  Widget _buildMembershipCard(UserMembershipModel um) {
    final isFrozen = um.isFrozen;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // ── Header card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFrozen
                  ? [Colors.grey.shade400, Colors.grey.shade600]
                  : [const Color(0xFF0D47A1), const Color(0xFF42A5F5)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Level ${um.level}",
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isFrozen) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "❄️ Frozen",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      um.membershipName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      um.branchName,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${um.daysRemaining}",
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "hari tersisa",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Action buttons ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Baris 1: Freeze & Renew
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: isFrozen ? "Unfreeze" : "Freeze",
                        icon: isFrozen ? Icons.play_arrow : Icons.ac_unit,
                        color: isFrozen ? Colors.green : Colors.lightBlue,
                        onTap: () => _toggleFreeze(um),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        label: "Renew",
                        icon: Icons.refresh,
                        color: const Color(0xFF4285F4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentPage(
                                membershipId: um.membershipId,
                                transactionType: 'renew',
                                userMembershipId: um.id,
                              ),
                            ),
                          ).then((_) => _loadMemberships());
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Baris 2: Upgrade & Downgrade
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: "Upgrade",
                        icon: Icons.arrow_upward,
                        color: Colors.orange,
                        onTap: () => _showUpgradeSheet(um),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        label: "Downgrade",
                        icon: Icons.arrow_downward,
                        color: Colors.redAccent,
                        onTap: () => _showDowngradeSheet(um),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}