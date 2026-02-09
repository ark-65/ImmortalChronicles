import 'package:flutter/material.dart';

import 'pages/splash_page.dart';

void main() {
  runApp(const LifeSimApp());
}

class LifeSimApp extends StatelessWidget {
  const LifeSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '人生重开·多界版',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
