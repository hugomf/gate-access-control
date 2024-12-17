import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GuestEditScreen extends StatefulWidget {
  final String guestId;
  final String currentName;
  final String currentPhone;
  final String currentEmail;
  final String currentReason;
  final Function fetchGuestsCallback;

  GuestEditScreen({
    required this.guestId,
    required this.currentName,
    required this.currentPhone,
    required this.currentEmail,
    required this.currentReason,
    required this.fetchGuestsCallback,
  });

  @override
  _GuestEditScreenState createState() => _GuestEditScreenState();
}

class _GuestEditScreenState extends State<GuestEditScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _reasonController = TextEditingController();


  String? selectedReason;

  Future<void> updateGuest() async {
    const url = 'http://localhost:5001/api/guests'; // Your backend URL

    try {
      final response = await http.put(
        Uri.parse('$url/${widget.guestId}'), // Append guest ID to URL
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'reason': _reasonController.text,
        }),
      );

      if (response.statusCode == 200) {
        widget.fetchGuestsCallback(); // Refresh the guest list
        Navigator.pop(context); // Go back to the list screen
      } else {
        throw Exception('Failed to update guest');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating guest: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _phoneController.text = widget.currentPhone;
    _emailController.text = widget.currentEmail;
    _reasonController.text  = widget.currentReason;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Guest')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
           TextField(
              controller: _reasonController,
              decoration: InputDecoration(labelText: 'Reason'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateGuest,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
