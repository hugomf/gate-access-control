import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  QrScannerScreenState createState() => QrScannerScreenState();
}

class QrScannerScreenState extends State<QrScannerScreen> {
  
  
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  
  String _qrResult = "Scan a QR code";
  final bool _isScanning = true;

  // This will hold scanned QR code data for future reference (local storage or database)
  final List<String> _scannedData = [];

  // API URL for saving QR data to a backend (adjust with your actual backend)
  final String apiUrl = 'https://your-api-url.com/scan-records';

  // Called when the QR view is created
  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _qrResult = scanData.code; // Update scanned data
      });
    });
  }

  // Function to save scanned QR data (simulating API call or local storage)
  Future<void> _saveScannedData() async {
    if (_qrResult.isNotEmpty) {
      // Record scanned QR data in a list (you can later save it to your DB)
      setState(() {
        _scannedData.add(_qrResult);
      });

      // Optionally, you can also make a request to save this to a backend
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: json.encode({'data': _qrResult}),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('QR Data saved successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save QR data')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving QR data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _qrKey.currentState?.dispose(); // Dispose QR controller properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Scanner')),
      body: Column(
        children: [
          // QR Scanner view
          Expanded(
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Scanned QR Code: $_qrResult',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: _isScanning ? _saveScannedData : null, // Only allow save if scanning is done
            child: Text('Save Scanned QR'),
          ),
          Divider(),
          // Display the list of scanned QR codes
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Previously Scanned QR Codes:", style: TextStyle(fontSize: 16)),
                ..._scannedData.map((data) => Text(data)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
