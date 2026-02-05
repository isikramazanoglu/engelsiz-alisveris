import 'dart:io';

import 'package:engelsiz_alisveris/views/mobile/mobile_scanning_screen.dart';
import 'package:engelsiz_alisveris/views/platform/desktop_scanning_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
