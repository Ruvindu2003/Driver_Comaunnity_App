import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:qr_flutter/qr_flutter.dart';

class QRConnectionHelper {
  static Future<String?> getLocalIPAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error getting IP address: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>> generateConnectionInfo() async {
    final ip = await getLocalIPAddress();
    final port = 5555; // Default ADB port
    
    return {
      'ip': ip ?? '192.168.1.100',
      'port': port,
      'connection_string': '${ip ?? '192.168.1.100'}:$port',
      'qr_data': 'adb:${ip ?? '192.168.1.100'}:$port',
      'instructions': [
        '1. Enable Developer Options on your phone',
        '2. Enable USB Debugging',
        '3. Connect phone to same WiFi network',
        '4. Run: adb tcpip 5555',
        '5. Run: adb connect ${ip ?? '192.168.1.100'}:$port',
        '6. Run: flutter run'
      ]
    };
  }

  static Widget buildConnectionDialog(BuildContext context) {
    debugPrint('Building QR connection dialog');
    return FutureBuilder<Map<String, dynamic>>(
      future: generateConnectionInfo(),
      builder: (context, snapshot) {
        debugPrint('QR dialog snapshot state: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('QR dialog error: ${snapshot.error}');
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error loading connection info: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        }

        final data = snapshot.data ?? {};
        final ip = data['ip'] ?? 'Unknown';
        final port = data['port'] ?? 5555;
        final connectionString = data['connection_string'] ?? 'Unknown';
        final instructions = data['instructions'] ?? [];
        
        debugPrint('QR dialog data: IP=$ip, Port=$port, Connection=$connectionString');

        return AlertDialog(
          title: const Text('Connect to Phone'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connection Details:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('IP Address: $ip'),
                        Text('Port: $port'),
                        Text('Connection: $connectionString'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Setup Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...instructions.map((instruction) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $instruction'),
                )),
                const SizedBox(height: 16),
                const Text(
                  'QR Code for Easy Connection:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: connectionString,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          connectionString,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Scan this QR code with your phone',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Copy to clipboard
                Clipboard.setData(ClipboardData(text: connectionString));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connection string copied to clipboard')),
                );
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }
}
