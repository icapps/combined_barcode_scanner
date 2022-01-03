import 'package:combined_barcode_scanner/src/scanner_configuration.dart';
import 'package:flutter/foundation.dart';

@immutable
class ScannerProperties {
  final bool hasUI;
  final Set<BarcodeFormat> supportedFormats;

  const ScannerProperties({
    required this.hasUI,
    required this.supportedFormats,
  });
}
