# Blue bird combined scanner implementation

This implementation of a combined scanner (see https://pub.dev/packages/combined_barcode_scanner)
uses the https://pub.dev/packages/blue_bird_scanner package to interface with the
blue bird hardware scanners.

Please follow the installation instructions in https://pub.dev/packages/combined_barcode_scanner

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
  ),
  scanners: [BlueBirdBarcodeScanner()],
);
```