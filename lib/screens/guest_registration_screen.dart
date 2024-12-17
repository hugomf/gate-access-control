import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class GuestRegistrationScreen extends StatefulWidget {
  final Function fetchGuestsCallback;

  const GuestRegistrationScreen({super.key, required this.fetchGuestsCallback});

  @override
  GuestRegistrationScreenState createState() =>
      GuestRegistrationScreenState();
}

class GuestRegistrationScreenState extends State<GuestRegistrationScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _qrCodeData;

  Future<void> saveGuest() async {
    const url = 'http://localhost:5001/api/guests'; // Your backend URL
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'email': _emailController.text,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'reason': _reasonController.text,
        }),
      );

      if (response.statusCode == 201) {
        final guest = json.decode(response.body);
        setState(() {
          _qrCodeData = guest['_id'];  // Assuming _id is unique for the guest
        });
        widget.fetchGuestsCallback();
      } else {
        throw Exception('Failed to save guest');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving guest: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Guest Registration')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(labelText: 'Reason'),
            ),
            ElevatedButton(
              onPressed: saveGuest,
              child: Text('Save Guest'),
            ),
            if (_qrCodeData != null) ...[
              SizedBox(height: 20),
              Text("QR Code for ${_nameController.text}:"),
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.white,  // Optional: Add styling for the QR code container
                child: QrImageView(
                  data: _qrCodeData!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);  // Manually close the screen
                },
                child: Text('Done'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
