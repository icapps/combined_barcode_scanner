# Zebra combined scanner implementation

This implementation of a combined scanner (see https://pub.dev/packages/combined_barcode_scanner)
interfaces with the zebra hardware scanners to implement scanning behaviour

Please follow the installation instructions in https://pub.dev/packages/combined_barcode_scanner

### Example
```dart
final widget = BarcodeScannerWidget(
  controller: _controller,
  onScan: (code) {
    if (kDebugMode) {
      print("GOT BARCODE =========== ${code.code}");
    }
  },
  configuration: const ScannerConfiguration(
    enableFormats: {BarcodeFormat.qr},
  ),
  scanners: [ZebraBarcodeScanner('myProfile')],
);
```