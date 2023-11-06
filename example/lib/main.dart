import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:combined_barcode_scanner_blue_bird/combined_barcode_scanner_blue_bird.dart';
import 'package:combined_barcode_scanner_fast/combined_barcode_scanner_fast.dart';
import 'package:combined_barcode_scanner_honeywell/combined_barcode_scanner_honeywell.dart';
import 'package:combined_barcode_scanner_unitech/combined_barcode_scanner_unitech.dart';
import 'package:combined_barcode_scanner_usb_keyboard/combined_barcode_scanner_usb_keyboard.dart';
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
  late final _controller = BarcodeScannerWidgetController(_onScannerLoaded);

  bool _supportsSwitchingCamera = false;
  bool _supportsSwitchingTorch = false;
  bool _supportsZebraScan = false;
  String? _code;

  final _scanners = [
    FastBarcodeScanner(),
    HoneywellBarcodeScanner(),
    UnitechBarcodeScanner(),
    BlueBirdBarcodeScanner(),
    ZebraBarcodeScanner('my_profile'),
    UsbKeyboardScanner(),
  ];

  @override
  void initState() {
    super.initState();
    _controller.supportsSwitchingCamera.then((bool value) => setState(() => _supportsSwitchingCamera = value));
    _controller.supportsSwitchingTorch.then((bool value) => setState(() => _supportsSwitchingTorch = value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScannerLoaded() {
    setState(() {
      _supportsZebraScan = _controller.supportsScanner<ZebraBarcodeScanner>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRect(
              child: BarcodeScannerWidget(
                controller: _controller,
                onScan: (code) {
                  setState(() {
                    _code = code.code;
                  });
                  print("GOT BARCODE =========== ${code.code}");
                },
                configuration: const ScannerConfiguration(
                  trimWhiteSpaces: true,
                  enableFormats: {
                    BarcodeFormat.qr,
                    BarcodeFormat.code128,
                  },
                  cameraConfiguration: CameraConfiguration(
                    frameRate: 30,
                    mode: BarcodeDetectionMode.continuous,
                    resolution: CameraResolution.medium,
                    type: CameraType.back,
                  ),
                ),
                scanners: _scanners,
              ),
            ),
          ),
          Text(
            'Code: ${_code ?? 'N/A'}',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_supportsSwitchingTorch) ...[
                MaterialButton(
                  child: Icon(
                    _controller.isTorchOn ? Icons.flash_off : Icons.flash_on,
                  ),
                  onPressed: () {
                    _controller.toggleTorch();
                    setState(() {});
                  },
                ),
              ],
              if (_supportsSwitchingCamera) ...[
                MaterialButton(
                  child: Icon(Icons.flip_camera_ios),
                  onPressed: _controller.toggleCamera,
                ),
              ],
              if (_supportsZebraScan) ...[
                Icon(Icons.barcode_reader),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
