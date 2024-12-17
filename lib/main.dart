import 'package:access_control/menu/app_drawer.dart';
import 'package:access_control/screens/guest_list_screen.dart';
import 'package:access_control/screens/qr_scanner_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(AccessControlApp());
}

class AccessControlApp extends StatelessWidget {
  const AccessControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Access Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Control')),
      drawer: const AppDrawer(),
      body: const HomeContent(),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Access Control',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ActionButton(
            label: 'Guest List',
            onPressed: () => _navigateTo(context, GuestListScreen()),
          ),
          const SizedBox(height: 20),
          ActionButton(
            label: 'Scan QR',
            onPressed: () => _navigateTo(context, QrScannerScreen()),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
