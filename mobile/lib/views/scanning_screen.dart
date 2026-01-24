import 'dart:io';

import 'package:engelsiz_alisveris/views/platform/desktop_scanning_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:engelsiz_alisveris/core/services/tts_service.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import '../data/services/product_service.dart';
import '../data/models/product_model.dart';

class ScanningScreen extends StatelessWidget {
  const ScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return const DesktopScanningScreen();
    } else {
      return const MobileScanningScreen();
    }
  }
}

class MobileScanningScreen extends StatefulWidget {
  const MobileScanningScreen({super.key});

  @override
  State<MobileScanningScreen> createState() => _MobileScanningScreenState();
}

class _MobileScanningScreenState extends State<MobileScanningScreen> {
  CameraController? _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TtsService _ttsService = TtsService();
  final ProductService _productService = ProductService();
  
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  DateTime? _lastScanTime;
  String? _lastScannedBarcode;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // İzin iste
    var status = await Permission.camera.request();
    if (status.isDenied) {
      _ttsService.speak("Kamera izni verilmedi. Uygulamayı kullanmak için izin vermelisiniz.");
      return;
    }

    // Kameraları listele
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      _ttsService.speak("Kamera bulunamadı.");
      return;
    }

    // Arka kamerayı seç (genelde 0, ama firstWhere ile garantiye alalım)
    final firstCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(FlashMode.off); // Başlangıçta flaş kapalı
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _ttsService.speak("Kamera başlatıldı. Barkodu veya etiketi kameraya tutun.");
        _startImageStream();
      }
    } catch (e) {
      print("Kamera hatası: $e");
      _ttsService.speak("Kamera başlatılamadı.");
    }
  }

  void _startImageStream() {
    _cameraController!.startImageStream((CameraImage image) {
      if (_isProcessing) return;
      _isProcessing = true;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final barcodes = await _barcodeScanner.processImage(inputImage);
      
      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final rawValue = barcode.rawValue;

        if (rawValue != null) {
          _handleBarcodeDetected(rawValue);
        }
      }
    } catch (e) {
      print("Tarama hatası: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _handleBarcodeDetected(String barcodeValue) async {
    final now = DateTime.now();
    
    // Aynı barkodu tekrar okumak için en az 3 saniye bekle (Debounce)
    if (_lastScannedBarcode == barcodeValue && 
        _lastScanTime != null && 
        now.difference(_lastScanTime!).inSeconds < 3) {
      return;
    }

    _lastScannedBarcode = barcodeValue;
    _lastScanTime = now;

    // Geri bildirim
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
    
    print("Barkod bulundu: $barcodeValue");
    await _ttsService.speak("Barkod okundu.");
    
    // Ürün bilgisini çek ve oku
    await _fetchAndSpeakProductInfo(barcodeValue);
  }

  Future<void> _fetchAndSpeakProductInfo(String barcode) async {
    try {
      print("Ürün aranıyor: $barcode");
      final product = await _productService.getProductByBarcode(barcode);
      
      if (product != null) {
        String speakText = "Ürün: ${product.name}. Fiyatı: ${product.price} Türk Lirası. ${product.description ?? ''}";
        await _ttsService.speak(speakText);
      } else {
        await _ttsService.speak("Ürün bulunamadı.");
      }
    } catch (e) {
      print("Ürün getirme hatası: $e");
      await _ttsService.speak("Ürün bilgisi alınamadı.");
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;
    
    // Android için InputImage oluşturma
    final InputImageRotation rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ?? InputImageRotation.rotation0deg;
    final InputImageFormat format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    final plane = image.planes.first;
    
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: plane.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _barcodeScanner.close();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Tarayıcı")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Barkodu ekrana tutun",
                style: TextStyle(color: Colors.white, fontSize: 18, backgroundColor: Colors.black54),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "test_etiket",
            onPressed: () {
               _ttsService.speak("Etiket Okundu: Fırsat Ürünü. Çaykur Rize Çayı. Fiyatı 100 TL.");
            },
            label: const Text("TEST ETİKET"),
            icon: const Icon(Icons.text_fields),
            backgroundColor: Colors.orange,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "test_barkod",
            onPressed: () => _handleBarcodeDetected("123456789"),
            label: const Text("TEST BARKOD"),
            icon: const Icon(Icons.qr_code),
          ),
        ],
      ),
    );
  }
}
