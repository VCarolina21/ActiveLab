import 'package:activelab/config/services/user_session.dart';
import 'package:activelab/payment/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/branch_api_service.dart';
import '../services/membership_api_service.dart'; // Tambahkan import ini jika belum ada
import '../sign_in/sign_page.dart'; 

class MembershipDetailPage extends StatefulWidget {
  final MembershipModel membership;
  final int branchId;
  final String branchName;

  const MembershipDetailPage({
    super.key,
    required this.membership,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<MembershipDetailPage> createState() => _MembershipDetailPageState();
}

class _MembershipDetailPageState extends State<MembershipDetailPage> {
  bool _hasExistingMembership = false;
  bool _isCheckingMembership = false;

  @override
  void initState() {
    super.initState();
    _checkExistingMembership();
  }

  Future<void> _checkExistingMembership() async {
    final isLoggedIn = await UserSession.isLoggedIn();
    if (!isLoggedIn) return;

    setState(() => _isCheckingMembership = true);
    try {
      final memberships = await MembershipApiService.getUserMemberships();
      final hasExisting = memberships.any(
        (m) => m.branchId == widget.branchId && (m.status == 'active' || m.status == 'frozen'),
      );
      setState(() => _hasExistingMembership = hasExisting);
    } catch (_) {} finally {
      setState(() => _isCheckingMembership = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
          "Detail Membership",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                ),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Level ${widget.membership.level}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.membership.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.branchName,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        formatter.format(widget.membership.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${widget.membership.activeDays} Hari",
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if (widget.membership.description != null && widget.membership.description!.isNotEmpty) ...[
                    const Text(
                      "Deskripsi",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.membership.description!,
                      style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 25),
                  ],

                  const Text(
                    "Keuntungan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (widget.membership.benefits.isEmpty)
                    const Text("Tidak ada keuntungan tambahan", style: TextStyle(color: Colors.grey))
                  else
                    ...widget.membership.benefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3F2FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Color(0xFF4285F4), size: 16),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            b['name'] as String? ?? '',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _hasExistingMembership ? null : () async {
                final isLoggedIn = await UserSession.isLoggedIn();
                if (!context.mounted) return;
                if (!isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Silakan login terlebih dahulu")),
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SignPage()));
                  return;
                }
                _showPaymentMethodSheet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isCheckingMembership
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      _hasExistingMembership
                          ? "Sudah Punya Membership di Cabang Ini"
                          : "Beli — ${formatter.format(widget.membership.price)}",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Metode Pembayaran",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4285F4), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.qr_code, color: Color(0xFF4285F4), size: 30),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("QRIS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Bayar dengan scan QR Code", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.check_circle, color: Color(0xFF4285F4)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Tutup bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentPage(
                        membershipId: widget.membership.id,
                        transactionType: 'new',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}