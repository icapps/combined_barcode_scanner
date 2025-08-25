# fast_barcode_scanner combined scanner implementation

This implementation of a combined scanner (see https://pub.dev/packages/combined_barcode_scanner)
uses the keyboard input to detect scan codes.
Some external usb scanners are known to use keyboard input to input scan codes. (Eg. Zebra DS2208)

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
    enableFormats: {}, // supported formats are determined by the scanner itself
  ),
  scanners: [UsbKeyboardScanner(
    child: content, 
  )],
);
```