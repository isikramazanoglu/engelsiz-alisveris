import 'package:engelsiz_alisveris/core/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class DesktopScanningScreen extends StatefulWidget {
  const DesktopScanningScreen({super.key});

  @override
  State<DesktopScanningScreen> createState() => _DesktopScanningScreenState();
}

class _DesktopScanningScreenState extends State<DesktopScanningScreen> {
  final TtsService _ttsService = TtsService();
  String _scanResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Masaüstü/Web Tarayıcı")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ));
                setState(() {
                  if (res is String) {
                    _scanResult = res;
                    _handleBarcodeDetected(res);
                  }
                });
              },
              child: const Text('Barkod Tara'),
            ),
            const SizedBox(height: 20),
            if (_scanResult.isNotEmpty)
              Text("Bulunan Barkod: $_scanResult", style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  void _handleBarcodeDetected(String barcodeValue) async {
    if (barcodeValue == '-1' || barcodeValue.isEmpty) return;
    
    print("Barkod bulundu: $barcodeValue");
    await _ttsService.speak("Barkod okundu: $barcodeValue");
    // API isteği buraya
  }
}
