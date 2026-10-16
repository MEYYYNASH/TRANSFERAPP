import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'theme/pixel_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PixelDropApp());
}

class PixelDropApp extends StatelessWidget {
  const PixelDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIXELDROP',
      debugShowCheckedModeBanner: false,
      theme: PixelTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
