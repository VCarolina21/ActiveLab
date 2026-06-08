import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/membership_api_service.dart';
import '../payment/payment_page.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with SingleTickerProviderStateMixin {
  List<UserMembershipModel> _memberships = [];
  bool _isLoading = true;
  String? _errorMsg;
  late AnimationController _animController;

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // ─── Design Tokens ───────────────────────────────────────────────
  static const _bg = Color(0xFFF7F8FC);
  static const _surface = Colors.white;
  static const _primary = Color(0xFF3B5BDB);
  static const _primaryLight = Color(0xFF748FFC);
  static const _textPrimary = Color(0xFF1A1D2E);
  static const _textSecondary = Color(0xFF8B92A5);
  static const _border = Color(0xFFEAECF3);
  static const _frozenStart = Color(0xFF74C0FC);
  static const _frozenEnd = Color(0xFF339AF0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadMemberships();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberships() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final data = await MembershipApiService.getUserMemberships();
      setState(() {
        _memberships = data;
      });
      _animController.forward(from: 0);
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
      });
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFFA5252)
            : const Color(0xFF40C057),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showUpgradeSheet(UserMembershipModel um) async {
    final options = await MembershipApiService.getUpgradeOptions(um.id);
    if (!mounted) return;
    if (options.isEmpty) {
      _showSnack("Tidak ada opsi upgrade tersedia", isError: true);
      return;
    }
    _showMembershipOptionsSheet(
      title: "Upgrade Membership",
      subtitle: "Pilih paket yang lebih tinggi",
      iconData: Icons.trending_up_rounded,
      iconColor: const Color(0xFFFF922B),
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
      title: "Downgrade Membership",
      subtitle: "Pilih paket yang lebih rendah",
      iconData: Icons.trending_down_rounded,
      iconColor: const Color(0xFFFA5252),
      options: options,
      onSelect: (selectedId) async {
        try {
          await MembershipApiService.downgrade(um.id, selectedId);
          _showSnack("Membership berhasil di-downgrade");
          _loadMemberships();
        } catch (e) {
          _showSnack(
            e.toString().replaceFirst('Exception: ', ''),
            isError: true,
          );
        }
      },
    );
  }

  void _showCancelMembershipDialog(UserMembershipModel um) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.do_not_disturb_on_outlined,
                  size: 32,
                  color: Color(0xFFFA5252),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Berhenti Berlangganan?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Membership \"${um.membershipName}\" di ${um.branchName} akan dinonaktifkan. Sisa hari tidak dapat dikembalikan.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 13.5,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await MembershipApiService.cancelMembership(um.id);
                          _showSnack("Membership berhasil diberhentikan");
                          _loadMemberships();
                        } catch (e) {
                          _showSnack(
                            e.toString().replaceFirst('Exception: ', ''),
                            isError: true,
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFA5252),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFFFDEDE)),
                        ),
                      ),
                      child: const Text(
                        "Ya, Berhenti",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMembershipOptionsSheet({
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconColor,
    required List<Map<String, dynamic>> options,
    required void Function(int selectedId) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...options.map((opt) {
              final price = double.tryParse(opt['price'].toString()) ?? 0;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onSelect(opt['id'] as int);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          "Lv ${opt['level']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        formatter.format(price),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _textSecondary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _textPrimary,
              size: 20,
            ),
          ),
        ),
        title: const Text(
          "My Memberships",
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _loadMemberships,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 16, 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: _textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: _primary,
                backgroundColor: _primary.withOpacity(0.12),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Memuat membership...",
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 40,
                  color: Color(0xFFFA5252),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadMemberships,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text("Coba Lagi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_memberships.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.card_membership_rounded,
                  size: 44,
                  color: _primary.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Belum ada membership aktif",
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Beli membership dari halaman Explore",
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: _memberships.length,
      itemBuilder: (_, i) {
        final delay = i * 80;
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final t = ((_animController.value * 1000 - delay) / 400).clamp(
              0.0,
              1.0,
            );
            final curve = Curves.easeOutCubic.transform(t);
            return Transform.translate(
              offset: Offset(0, 24 * (1 - curve)),
              child: Opacity(opacity: curve, child: child),
            );
          },
          child: _buildMembershipCard(_memberships[i]),
        );
      },
    );
  }

  Widget _buildMembershipCard(UserMembershipModel um) {
    final isFrozen = um.isFrozen;
    final gradientColors = isFrozen
        ? [_frozenStart, _frozenEnd]
        : [_primary, _primaryLight];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(isFrozen ? 0.04 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _statusChip(
                            label: "Level ${um.level}",
                            bg: Colors.white.withOpacity(0.2),
                            textColor: Colors.white,
                          ),
                          if (isFrozen) ...[
                            const SizedBox(width: 6),
                            _statusChip(
                              label: "❄️ Frozen",
                              bg: Colors.white.withOpacity(0.2),
                              textColor: Colors.white,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        um.membershipName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            um.branchName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // days remaining badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${um.daysRemaining}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "hari\ntersisa",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Actions ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: isFrozen ? "Unfreeze" : "Freeze",
                        icon: isFrozen
                            ? Icons.play_arrow_rounded
                            : Icons.ac_unit_rounded,
                        color: isFrozen
                            ? const Color(0xFF40C057)
                            : const Color(0xFF339AF0),
                        onTap: () => _toggleFreeze(um),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        label: "Renew",
                        icon: Icons.autorenew_rounded,
                        color: _primary,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: "Upgrade",
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFFFF922B),
                        onTap: () => _showUpgradeSheet(um),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        label: "Downgrade",
                        icon: Icons.trending_down_rounded,
                        color: const Color(0xFFFA5252),
                        onTap: () => _showDowngradeSheet(um),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _actionButton(
                  label: "Berhenti Berlangganan",
                  icon: Icons.remove_circle_outline_rounded,
                  color: _textSecondary,
                  onTap: () => _showCancelMembershipDialog(um),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required Color bg,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isDestructive ? _bg : color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? _border : color.withOpacity(0.18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
