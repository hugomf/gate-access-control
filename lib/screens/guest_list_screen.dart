import 'dart:convert';
import 'package:access_control/screens/guest_registration_screen.dart';
import 'package:access_control/screens/guest_edit_screen.dart'; // Import GuestEditScreen
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class GuestListScreen extends StatefulWidget {
  @override
  _GuestListScreenState createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  List<dynamic> _guests = [];
  bool _isLoading = true;
  bool _hasError = false;

  // URL for fetching guests
  final String _apiUrl = 'http://localhost:5001/api/guests';

  // Fetch guests from the API
  Future<void> fetchGuests() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _guests = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch guests');
      }
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching guests: $error')),
      );
    }
  }

  // Delete a guest from the backend
  Future<void> removeGuest(String guestId) async {
    final url = '$_apiUrl/$guestId'; // Add the guest's ID to the API URL
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        // Successfully deleted, update the list
        setState(() {
          _guests.removeWhere((guest) => guest['_id'] == guestId);
        });
      } else {
        throw Exception('Failed to delete guest');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting guest: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGuests(); // Fetch guests when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Guest List')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner while fetching
          : _hasError
              ? _buildErrorState() // Show error state with retry
              : _buildGuestList(), // Show the list of guests
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the GuestRegistrationScreen to add a new guest
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuestRegistrationScreen(
                fetchGuestsCallback: fetchGuests, // Pass callback to refresh guest list
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Guest',
      ),
    );
  }

  // Method to build the guest list UI
  Widget _buildGuestList() {
    return ListView.builder(
      itemCount: _guests.length,
      itemBuilder: (ctx, index) {
        final guest = _guests[index];
        return ListTile(
          leading: QrImageView(
            data: guest['_id'],
            version: QrVersions.auto,
            size: 50.0,
          ),
          title: Text(guest['name']),
          subtitle: Text('Phone: ${guest['phone']}\nRegistered on: ${guest['createdAt']}'),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  // Navigate to the edit screen when the edit button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                     builder: (context) => GuestEditScreen(
                        guestId: guest["_id"],
                        currentName: guest["name"] ?? '',
                        currentPhone: guest["phone"] ?? '',
                        currentEmail: guest["email"] ?? '',
                        currentReason: guest["reason"] ?? '',
                        fetchGuestsCallback: fetchGuests,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Show a confirmation dialog before deleting
                  _showDeleteConfirmationDialog(guest['_id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to show the confirmation dialog for deleting a guest
  void _showDeleteConfirmationDialog(String guestId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to remove this guest?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              removeGuest(guestId); // Remove guest if confirmed
              Navigator.of(ctx).pop(); // Close the dialog
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Method to build error state UI with retry option
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 50),
          SizedBox(height: 20),
          Text('Failed to load guests. Please try again.',
              style: TextStyle(fontSize: 18, color: Colors.black)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchGuests, // Retry fetching guests
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
