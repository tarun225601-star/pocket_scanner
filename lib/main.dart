import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const PocketScannerApp());
}

class PocketScannerApp extends StatelessWidget {
  const PocketScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  bool isScanning = false;
  String scanResult = "";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _toggleConnection() {
    setState(() {
      isConnected = !isConnected;
      if (!isConnected) {
        scanResult = "";
      }
    });
  }

  void _scanFaults() {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pehle OBD Scanner connect karein!')),
      );
      return;
    }

    setState(() {
      isScanning = true;
      scanResult = "";
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isScanning = false;
        scanResult = "P0300 - Spark Plug / Ignition Coil Malfunction";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isConnected ? Colors.green : Colors.red),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isConnected ? "Connected to JB_OBD" : "Disconnected",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isConnected ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _toggleConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isConnected ? "Disconnect" : "Connect"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  onPressed: isScanning ? null : _scanFaults,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    elevation: 8,
                  ),
                  child: isScanning
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner, size: 50),
                            SizedBox(height: 10),
                            Text(
                              "SCAN\nFAULTS",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (scanResult.isNotEmpty) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Detected Issue (AI Report):",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scanResult,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MechanicScreen(faultDetails: scanResult),
                    ),
                  );
                },
                icon: const Icon(Icons.near_me),
                label: const Text("Find Nearest Mechanic & Parts"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class MechanicScreen extends StatelessWidget {
  final String faultDetails;

  const MechanicScreen({super.key, required this.faultDetails});

  Future<void> _launchWhatsApp(String phone, String message) async {
    final url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchCall(String phone) async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    const mechanicName = "Sharma Auto Garage";
    const mechanicDistance = "1.2 KM";
    const mechanicPhone = "+919876543210"; 
    const mechanicAddress = "Near Main Market, Sector 12";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Mechanic'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          mechanicName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            mechanicDistance,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(mechanicAddress, style: TextStyle(color: Colors.grey)),
                    const Divider(height: 20),
                    Text(
                      "Issue to share: $faultDetails",
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _launchWhatsApp(
                        mechanicPhone,
                        "Hello, meri gaadi me yeh problem aayi hai: $faultDetails. Ye part aur solution chahiye.",
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text("WhatsApp"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _launchCall(mechanicPhone);
                    },
                    icon: const Icon(Icons.call),
                    label: const Text("Call Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
