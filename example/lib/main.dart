import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:combined_barcode_scanner_blue_bird/combined_barcode_scanner_blue_bird.dart';
import 'package:combined_barcode_scanner_fast/combined_barcode_scanner_fast.dart';
import 'package:combined_barcode_scanner_honeywell/combined_barcode_scanner_honeywell.dart';
import 'package:combined_barcode_scanner_unitech/combined_barcode_scanner_unitech.dart';
import 'package:combined_barcode_scanner_zebra/combined_barcode_scanner_zebra.dart';
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
    _controller = BarcodeScannerWidgetController(() {});
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
          print("GOT BARCODE =========== ${code.code}");
        },
        configuration: const ScannerConfiguration(
          enableFormats: {BarcodeFormat.qr},
          cameraConfiguration: CameraConfiguration(
            frameRate: 30,
            mode: BarcodeDetectionMode.continuous,
            resolution: CameraResolution.medium,
            type: CameraType.back,
          ),
        ),
        scanners: [
          FastBarcodeScanner(),
          HoneywellBarcodeScanner(),
          UnitechBarcodeScanner(),
          BlueBirdBarcodeScanner(),
          ZebraBarcodeScanner('my_profile'),
        ],
      ),
    );
  }
}
