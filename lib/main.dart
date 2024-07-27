import 'package:flutter/material.dart';
import 'screens/csv_to_qr_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV to QR Code Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CsvToQrScreen(),
    );
  }
}
