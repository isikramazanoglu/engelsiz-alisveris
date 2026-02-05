import 'package:camera/camera.dart';
import 'package:engelsiz_alisveris/core/providers/scanning_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileScanningScreen extends StatelessWidget {
  const MobileScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Engelsiz Tarayıcı"),
        actions: [
          Consumer<ScanningProvider>(
            builder: (context, provider, child) {
              return Semantics(
                label: "El fenerini ${provider.isFlashOn ? 'kapat' : 'aç'}",
                button: true,
                child: IconButton(
                  icon: Icon(
                    provider.isFlashOn ? Icons.flash_on : Icons.flash_off,
                    size: 30,
                    color: provider.isFlashOn ? Colors.yellow : Colors.grey,
                  ),
                  onPressed: () => provider.toggleFlash(),
                ),
              );
            },
          )
        ],
      ),
      body: Consumer<ScanningProvider>(
        builder: (context, provider, child) {
          if (!provider.isCameraInitialized || provider.cameraController == null) {
            return Center(
              child: Semantics(
                label: "Kamera başlatılıyor, lütfen bekleyin.",
                child: const CircularProgressIndicator(),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Kamera Önizlemesi (Semantics ile sarmalanmış)
              Semantics(
                label: "Kamera görüntüsü. Barkodu bulmak için cihazı ürünün üzerinde gezdirin.",
                hint: "Barkod algılandığında titreşim ve sesli uyarı alacaksınız.",
                child: CameraPreview(provider.cameraController!),
              ),

              // 2. Odak Alanı Çerçevesi (Görsel rehber)
              Center(
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // 3. Alt Bilgi Paneli (Ürün bulunduğunda görünür)
              if (provider.lastScannedProduct != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Semantics(
                    container: true,
                    label: "Son okunan ürün bilgileri paneli",
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.lastScannedProduct!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${provider.lastScannedProduct!.price} TL",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (provider.lastScannedProduct!.description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                provider.lastScannedProduct!.description!,
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => provider.replayLastProduct(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              icon: const Icon(Icons.volume_up, size: 28),
                              label: const Text("Tekrar Oku", style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
