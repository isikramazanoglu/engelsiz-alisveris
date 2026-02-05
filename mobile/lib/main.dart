import 'package:engelsiz_alisveris/core/providers/scanning_provider.dart';
import 'package:flutter/material.dart';
import 'package:engelsiz_alisveris/core/theme/app_theme.dart';
import 'package:engelsiz_alisveris/views/scanning_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const EngelsizApp());
}

class EngelsizApp extends StatelessWidget {
  const EngelsizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScanningProvider()),
      ],
      child: MaterialApp(
        title: 'Engelsiz Alışveriş',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Semantics (Erişilebilirlik) açık
        showSemanticsDebugger: false, 
        home: const ScanningScreen(),
      ),
    );
  }
}
