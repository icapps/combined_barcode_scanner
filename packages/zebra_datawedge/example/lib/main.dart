import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:combined_barcode_scanner_zebra/combined_barcode_scanner_zebra.dart';
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
  final _scanner = ZebraBarcodeScanner('myProfile');
  String? _imei;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = BarcodeScannerWidgetController(_getImei);
  }

  void _getImei() async {
    try {
      _loading = true;
      setState(() {});
      _imei = await _scanner.controller.imei;
      setState(() {});
      // ignore: avoid_print
      print("IMEI =========== $_imei");
    } catch (e) {
      // ignore: avoid_print
      print("ERROR =========== $e");
    }
    _loading = false;
    setState(() {});
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
      body: Column(
        children: [
          Text("Loading =========== $_loading"),
          Text("IMEI =========== $_imei"),
          ElevatedButton(
            onPressed: _getImei,
            child: const Text('retry'),
          ),
          Expanded(
            child: BarcodeScannerWidget(
              controller: _controller,
              onScan: (code) {
                if (kDebugMode) {
                  print("GOT BARCODE =========== ${code.code}");
                }
              },
              configuration: const ScannerConfiguration(
                enableFormats: {BarcodeFormat.qr},
              ),
              scanners: [_scanner],
            ),
          ),
        ],
      ),
    );
  }
}
