import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:flutter/widgets.dart';

abstract class BarcodeScanner {
  ScannerProperties get properties;

  Future<void> configure({
    required ScannerConfiguration configuration,
    required ValueChanged<String> onScan,
  });

  void dispose();

  Widget? buildUI(
    ScannerConfiguration configuration,
    BuildContext context,
  );
}
