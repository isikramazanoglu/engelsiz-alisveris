import 'package:flutter/material.dart';
import 'package:engelsiz_alisveris/core/theme/app_theme.dart';
import 'package:engelsiz_alisveris/views/scanning_screen.dart';

void main() {
  runApp(const EngelsizApp());
}

class EngelsizApp extends StatelessWidget {
  const EngelsizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Engelsiz Alışveriş',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Semantics (Erişilebilirlik) açık
      showSemanticsDebugger: false, 
      home: const ScanningScreen(),
    );
  }
}
