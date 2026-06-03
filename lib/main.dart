import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'utils/connectivity_check.dart'; 

void main() {
  runApp(const ActiveLabApp());
}

class ActiveLabApp extends StatefulWidget {
  const ActiveLabApp({super.key});

  @override
  State<ActiveLabApp> createState() => _ActiveLabAppState();
}

class _ActiveLabAppState extends State<ActiveLabApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Cek koneksi setelah frame pertama selesai di-render
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final connected = await ConnectivityCheck.isConnected();
      if (!connected && _navigatorKey.currentContext != null) {
        ConnectivityCheck.showNoConnectionDialog(_navigatorKey.currentContext!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Daftarkan navigatorKey di sini
      navigatorKey: _navigatorKey, 
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}