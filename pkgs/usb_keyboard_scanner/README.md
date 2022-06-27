# fast_barcode_scanner combined scanner implementation

This implementation of a combined scanner (see https://pub.dev/packages/combined_barcode_scanner)
uses the https://pub.dev/packages/fast_barcode_scanner package to scan qr codes

Please follow the installation instructions in https://pub.dev/packages/fast_barcode_scanner and https://pub.dev/packages/combined_barcode_scanner

### Example
```dart
BarcodeScannerWidget(
  controller: _controller,
  onScan: (code) {
    if (kDebugMode) {
      print("GOT BARCODE =========== ${code.code}");
    }
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
  scanners: [FastBarcodeScanner()],
);
```