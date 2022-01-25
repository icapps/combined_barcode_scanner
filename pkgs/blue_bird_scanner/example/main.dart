import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:combined_barcode_scanner_blue_bird/combined_barcode_scanner_blue_bird.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final BarcodeScannerWidgetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BarcodeScannerWidgetController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BarcodeScannerWidget(
        controller: _controller,
        onScan: (code) {
          if (kDebugMode) {
            print("GOT BARCODE =========== ${code.code}");
          }
        },
        configuration: const ScannerConfiguration(
          enableFormats: {BarcodeFormat.qr},
        ),
        scanners: [BlueBirdBarcodeScanner()],
      ),
    );
  }
}
