import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../explore/explore_page.dart';
import '../chat/chat_page.dart';
import '../sign_in/sign_page.dart';
import 'legal_policy_page.dart';
import 'membership_page.dart';

class ProfilePage extends StatefulWidget {
  final String userName;

  const ProfilePage({super.key, required this.userName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String membershipDuration = "12 Month";

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
                    border: Border.all(color: const Color(0xFFF06292), width: 4),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const SignPage()),
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
                          style: TextStyle(color: Color(0xFFF06292), fontWeight: FontWeight.bold),
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
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage('assets/profile.JPG'),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              widget.userName.isNotEmpty ? widget.userName : "User",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Id : 123456789",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.emoji_events, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    membershipDuration,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSectionTitle("Activity"),
                      _buildMenuCard([
                        _buildMenuItem(Icons.calendar_today_outlined, "My Bookings"),
                        _buildDivider(),
                        _buildMenuItem(
                          Icons.shopping_bag_outlined, 
                          "My Memberships",
                          onTap: () => _navigateToMembership(context),
                        ),
                        _buildDivider(),
                        _buildMenuItem(Icons.account_balance_wallet_outlined, "Payment Methods"),
                      ]),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Setup & Help"),
                      _buildMenuCard([
                        _buildMenuItem(
                          Icons.gavel_outlined, 
                          "Legal and Policies",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LegalPolicyPage()),
                            );
                          },
                        ),
                      ]),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton(
                            onPressed: () {
                              _showLogoutDialog(context); 
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red, width: 1.5),
                              backgroundColor: Colors.white.withValues(alpha: 0.9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _navItem(BuildContext context, IconData icon, String label, bool isActive, int index) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        if (isActive) return;
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(userName: widget.userName)));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExplorePage(userName: widget.userName)));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatPage(userName: widget.userName)));
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

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
          )
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
}