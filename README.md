# Combined barcode scanner
This package contains the basis for creating new barcode scanners that can be combined
into a single barcode scanner source.

To implement a custom scanner, import this package and implement your custom subclass
of `BarcodeScanner` and `BarcodeScannerController`

## Not found FastBarcodeScanner()

see https://github.com/icapps/combined_barcode_scanner/issues/8

We are waiting for a merge in one of the dependencies. While we wait, you can use this "temporary" workaround

## Example Usage
```dart
BarcodeScannerWidget(
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
  scanners: [FastBarcodeScanner()],
)
```
