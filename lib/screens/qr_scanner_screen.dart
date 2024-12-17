import 'dart:io';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? _qrResult;
  QRViewController? controller;
  final bool _isScanning = true;

  // This will hold scanned QR code data for future reference (local storage or database)
  final List<String> _scannedData = [];

  // API URL for saving QR data to a backend (adjust with your actual backend)
  final String apiUrl = 'http://localhost:5001/api/access';


    // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          )
        ],
      ),
    );
  }

  // Called when the QR view is created
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _qrResult = scanData;
         if (_qrResult != null && _qrResult!.format == BarcodeFormat.qrcode) {
          var code = _qrResult!.code;
          _saveScannedData(code);
        }
      });
    });
  }

  // Function to save scanned QR data (simulating API call or local storage)
  Future<void> _saveScannedData(String code) async {
    if (code.isNotEmpty) {
      // Record scanned QR data in a list (you can later save it to your DB)
      setState(() {
        _scannedData.add(code);
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
    controller?.dispose();
    //qrKey.currentState?.dispose(); // Dispose QR controller properly
    super.dispose();
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('QR Code Scanner')),
//       body: Column(
//         children: [
//           // QR Scanner view
//           Expanded(
//             child: QRView(
//               key: _qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Text(
//               'Scanned QR Code: $_qrResult',
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: _isScanning ? _saveScannedData : null, // Only allow save if scanning is done
//             child: Text('Save Scanned QR'),
//           ),
//           Divider(),
//           // Display the list of scanned QR codes
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Previously Scanned QR Codes:", style: TextStyle(fontSize: 16)),
//                 ..._scannedData.map((data) => Text(data)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
}