import 'dart:io';

import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:blue_bird_scanner/blue_bird_scanner.dart';

/// Barcode scanner implementation that uses the blue bird
/// hardware scanner where available.
///
/// Note: only a single blue bird scanner can be active at
/// the same time
class BlueBirdBarcodeScanner implements BarcodeScanner {
  final _scanner = BlueBirdScanner();
  var _supported = false;
  final BlueBirdModel model;

  @override
  late BarcodeScannerController controller;

  BlueBirdBarcodeScanner({this.model = BlueBirdModel.ef400_500});

  @override
  Widget? buildUI(ScannerConfiguration configuration, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Future<void> configure({
    required ScannerConfiguration configuration,
    required ValueChanged<BarcodeScanResult> onScan,
  }) async {
    _supported = !kIsWeb && Platform.isAndroid;
    if (_supported) {
      _scanner.scannerCallBack = _ScannerWrapper(onScan);

      await _scanner.initScanner(model);
    }
    controller = _BlueBirdController(_scanner, enabled: _supported);
  }

  @override
  void dispose() {
    if (_supported) {
      _scanner.scannerCallBack = _ScannerWrapper((_) {});
      _scanner.stopScanner();
    }
  }

  @override
  final ScannerProperties properties =
      const ScannerProperties(hasUI: false, supportedFormats: {
    BarcodeFormat.codabar,
    BarcodeFormat.code39,
    BarcodeFormat.code93,
    BarcodeFormat.code128,
    BarcodeFormat.ean8,
    BarcodeFormat.ean13,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
    BarcodeFormat.aztec,
    BarcodeFormat.dataMatrix,
    BarcodeFormat.maxiCode,
    BarcodeFormat.pdf417,
    BarcodeFormat.qr,
    BarcodeFormat.rss14,
    BarcodeFormat.rssExpanded,
  });
}

class _BlueBirdController implements BarcodeScannerController {
  final BlueBirdScanner _scanner;
  final bool enabled;

  _BlueBirdController(
    this._scanner, {
    required this.enabled,
  });

  @override
  void pause() {
    if (enabled) {
      _scanner.pauseScanner();
    }
  }

  @override
  void start() {
    if (enabled) {
      _scanner.startScanner();
    }
  }
}

class _ScannerWrapper implements ScannerCallBack {
  final ValueChanged<BarcodeScanResult> onScan;

  _ScannerWrapper(this.onScan);

  @override
  void onDecoded(String? result) {
    if (result != null) {
      onScan(BarcodeScanResult(code: result, format: null));
    }
  }

  @override
  void onError(Exception error) {}
}
