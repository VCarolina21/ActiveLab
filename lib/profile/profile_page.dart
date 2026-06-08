import 'package:activelab/login_page/login_page.dart';
import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../explore/explore_page.dart';
import '../chat/chat_page.dart';
import '../sign_in/sign_page.dart';
import '../scan/check_in_page.dart';
import '../home/notif_page.dart';
import 'legal_policy_page.dart';
import 'membership_page.dart';
import 'booking_page.dart';
import 'edit_profile_page.dart';
import '../config/services/user_api_services.dart';
import '../config/services/user_session.dart';
import '../config/app_config.dart';

class ProfilePage extends StatefulWidget {
  final String userName;

  const ProfilePage({super.key, required this.userName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String membershipDuration = "12 Month";
  String selectedPayment = "BCA";
  String _displayName = '';
  String? _photoUrl;
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final loggedIn = await UserSession.isLoggedIn();
    if (!loggedIn) {
      setState(() {
        _isGuest = true;
        _displayName = widget.userName.isNotEmpty ? widget.userName : 'Guest';
      });
      return;
    }

    final userData = await UserSession.getUserData();
    setState(() {
      _isGuest = false;
      _displayName = userData['name'] as String? ?? widget.userName;
      _photoUrl = AppConfig.buildUserPhotoUrl(userData['photo'] as String?);
    });
  }

  void _showLogoutDialog(BuildContext context) {
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
                    border: Border.all(
                      color: const Color(0xFFF06292),
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.question_mark,
                    size: 60,
                    color: Color(0xFFF06292),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Are You Sure?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Do you want to log out ?",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await UserSession.clearSession();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignPage(),
                            ),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF06292)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Log Out",
                          style: TextStyle(
                            color: Color(0xFFF06292),
                            fontWeight: FontWeight.bold,
                          ),
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
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
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
                    border: Border.all(color: Colors.red, width: 4),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Are You Sure?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Do you want to delete your account?",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          try {
                            await UserApiService.deleteAccount();
                          } catch (_) {}
                          await UserSession.clearSession();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToMembership(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MembershipPage()),
    );

    if (result != null && result is String) {
      setState(() {
        membershipDuration = result;
      });
    }
  }

  void _showPaymentMethodPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Payment Method",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPaymentOption(
                    setModalState,
                    "BCA",
                    "assets/logobca.png",
                  ),
                  const SizedBox(height: 15),
                  _buildPaymentOption(
                    setModalState,
                    "Mandiri",
                    "assets/logomandiri.png",
                  ),
                  const SizedBox(height: 15),
                  _buildPaymentOption(
                    setModalState,
                    "QRIS",
                    "assets/logoqris.png",
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption(
    StateSetter setModalState,
    String name,
    String imagePath,
  ) {
    bool isSelected = selectedPayment == name;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          selectedPayment = name;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF4285F4) : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 120,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4285F4)
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF4285F4)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            String title = "CoreFit Spa";
            String date = "24 May";
            String time = "11:00 AM";

            if (NotifPage.notifications.isNotEmpty) {
              final firstBooking = NotifPage.notifications.first;
              title = (firstBooking["title"] ?? "CoreFit Spa").toString();
              date = (firstBooking["date"] ?? "24 May").toString();
              time = (firstBooking["time"] ?? "11:00 AM").toString();
            }

            String assetImage = "assets/spa.JPG";
            String type = "SPA";
            String titleLower = title.toLowerCase();

            if (titleLower.contains("yoga")) {
              assetImage = "assets/yoga.JPG";
              type = "YOGA";
            } else if (titleLower.contains("hiit")) {
              assetImage = "assets/hiit.JPG";
              type = "HIIT";
            } else if (titleLower.contains("pilates")) {
              assetImage = "assets/pilates.JPG";
              type = "PILATES";
            } else if (titleLower.contains("massage")) {
              assetImage = "assets/massage.JPG";
              type = "MASSAGE";
            } else if (titleLower.contains("spa")) {
              assetImage = "assets/spa.JPG";
              type = "SPA";
            } else if (titleLower.contains("physio") ||
                titleLower.contains("terapi")) {
              assetImage = "assets/fisioterapi.JPG";
              type = "PHYSIOTHERAPY";
            } else if (titleLower.contains("gym")) {
              assetImage = "assets/gymuntar.jpg";
              type = "GYM";
            }

            int dayNum = 24;
            final RegExp matchDay = RegExp(r'^\d+');
            if (matchDay.hasMatch(date)) {
              dayNum = int.parse(matchDay.stringMatch(date)!);
            }

            String monthYear = date.replaceFirst(matchDay, '').trim();
            if (monthYear.contains(",")) {
              monthYear = monthYear.split(",").first.trim();
            }

            if (monthYear.isEmpty) {
              monthYear = "May 2026";
            } else if (!monthYear.contains("2026")) {
              monthYear = "$monthYear 2026";
            }

            String finalBookingRange = "$dayNum $monthYear";

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckInPage(
                  dateString: "$date, $time",
                  gymName: title,
                  location: "Jakarta",
                  rating: 4.9,
                  imagePath: assetImage,
                  bookingDates: finalBookingRange,
                  guestInfo: "2 Guests (1 Room)",
                  roomType: type,
                  phoneNumber: "0214345646",
                  status: "Pending",
                ),
              ),
            );
          },
          backgroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.crop_free, color: Colors.black, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Column(
        children: [
          // ── Header modern ──────────────────────────────────
          _buildProfileHeader(context),
          // ── Content scrollable ─────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Activity"),
                  const SizedBox(height: 10),
                  _buildModernMenuCard([
                    _buildModernMenuItem(
                      Icons.calendar_today_rounded,
                      "My Bookings",
                      const Color(0xFF1A6FD4),
                      const Color(0xFFDEEEFF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingPage(),
                          ),
                        );
                      },
                    ),
                    _buildModernMenuItem(
                      Icons.card_membership_rounded,
                      "My Memberships",
                      const Color(0xFF0F6E56),
                      const Color(0xFFDEF7EC),
                      onTap: () => _navigateToMembership(context),
                    ),
                    _buildModernMenuItem(
                      Icons.account_balance_wallet_rounded,
                      "Payment Methods",
                      const Color(0xFFD4681A),
                      const Color(0xFFFFF0E0),
                      onTap: () => _showPaymentMethodPopup(context),
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Setup & Help"),
                  const SizedBox(height: 10),
                  _buildModernMenuCard([
                    _buildModernMenuItem(
                      Icons.gavel_rounded,
                      "Legal and Policies",
                      const Color(0xFF5B4CF5),
                      const Color(0xFFEEEBFF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LegalPolicyPage(),
                          ),
                        );
                      },
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 32),
                  // Tombol Logout
                  _buildDangerButton(
                    label: "Logout",
                    icon: Icons.logout_rounded,
                    onTap: () => _showLogoutDialog(context),
                  ),
                  const SizedBox(height: 12),
                  // Tombol Hapus Akun
                  _buildDangerButton(
                    label: "Hapus Akun",
                    icon: Icons.delete_forever_rounded,
                    onTap: () => _showDeleteAccountDialog(context),
                    isDanger: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              // Title row
              const Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Avatar + nama + tombol edit
              Column(
                children: [
                  // Avatar dengan ring
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (_photoUrl != null && _photoUrl!.isNotEmpty)
                          ? NetworkImage(_photoUrl!) as ImageProvider
                          : const AssetImage('assets/profile.JPG'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _displayName.isNotEmpty ? _displayName : 'Guest',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tombol Edit Profile / Login
                  _isGuest
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                            _loadUserData();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF8A97B0),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildModernMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A6FD4).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildModernMenuItem(
    IconData icon,
    String title,
    Color iconColor,
    Color iconBg, {
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(18),
            bottom: isLast ? const Radius.circular(18) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF8A97B0),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: Color(0xFFF0F4FB),
          ),
      ],
    );
  }

  Widget _buildDangerButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDanger ? const Color(0xFFA32D2D) : const Color(0xFFE05050),
            width: 1.5,
          ),
          backgroundColor: isDanger ? const Color(0xFFFCEBEB) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDanger
                  ? const Color(0xFFA32D2D)
                  : const Color(0xFFE05050),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDanger
                    ? const Color(0xFFA32D2D)
                    : const Color(0xFFE05050),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Legacy helpers — masih dipakai oleh widget lama, dibiarkan
  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: Color(0xFFF0F0F0),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      shape: const CircularNotchedRectangle(),
      notchMargin: 12.0,
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _navItem(context, Icons.home_outlined, "Home", false, 0),
              _navItem(context, Icons.search, "Explore", false, 1),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _navItem(context, Icons.chat_bubble_outline, "Chat", false, 2),
              _navItem(context, Icons.person, "Profile", true, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    int index,
  ) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        if (isActive) return;
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userName: _displayName),
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExplorePage(userName: _displayName),
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
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
