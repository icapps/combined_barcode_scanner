import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:combined_barcode_scanner_unitech/src/scanner/scan_callback.dart';
import 'package:combined_barcode_scanner_unitech/src/scanner/unitech_scanner_controller.dart';
import 'package:flutter/widgets.dart';

/// Barcode scanner implementation that uses the unitech
/// hardware scanner where available.
///
///
/// Note: only a single unitech scanner can be active at
/// the same time
class UnitechBarcodeScanner implements BarcodeScanner {
  final _controller = UnitechScannerController();
  var _supported = false;

  @override
  late BarcodeScannerController controller;

  @override
  Widget? buildUI(
    ScannerConfiguration configuration,
    BuildContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> configure({
    required ScannerConfiguration configuration,
    required ValueChanged<BarcodeScanResult> onScan,
  }) async {
    _supported = await _controller.isControllerSupported;
    _controller.scannerCallBack = _ScannerWrapper(onScan);
    controller = _UnitechController(_controller, enabled: _supported);
  }

  @override
  void dispose() {
    _controller.scannerCallBack = _ScannerWrapper((_) {});
  }

  @override
  final ScannerProperties properties = const ScannerProperties(
    hasUI: false,
    supportedFormats: {
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.codabar,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.rssExpanded,
      BarcodeFormat.rss14,
      BarcodeFormat.pdf417,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.qr,
      BarcodeFormat.aztec,
      BarcodeFormat.maxiCode,
    },
  );
}

class _ScannerWrapper implements UnitechScannerCallBack {
  final ValueChanged<BarcodeScanResult> onScan;

  _ScannerWrapper(this.onScan);

  @override
  void onDecoded(String? result) {
    if (result != null) {
      onScan(
        BarcodeScanResult(
          code: result,
          format: null,
          source: ScannerType.unitech,
        ),
      );
    }
  }

  @override
  void onError(Exception error) {}
}

class _UnitechController extends BarcodeScannerController {
  final UnitechScannerController _scanner;
  final bool enabled;

  @override
  bool get isControllerSupported => enabled;

  _UnitechController(
    this._scanner, {
    required this.enabled,
  });

  @override
  void pause() {
    if (enabled) {
      _scanner.stopScanning();
    }
  }

  @override
  void start() {
    if (enabled) {
      _scanner.startScanning();
    }
  }
}
