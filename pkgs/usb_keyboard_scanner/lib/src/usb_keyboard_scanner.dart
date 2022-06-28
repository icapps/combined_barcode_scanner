import 'dart:async';

import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Barcode scanner implementation that uses the fast_barcode_scanner library.
///
/// Please follow the installation instructions in
/// [https://pub.dev/packages/fast_barcode_scanner]
class UsbKeyboardScanner implements BarcodeScanner {
  late ValueChanged<BarcodeScanResult> _onScan;
  late FocusNode _focusNode;

  @override
  Widget? buildUI(ScannerConfiguration configuration, BuildContext context) =>
      KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: const SizedBox(),
      );

  @override
  Future<void> configure({
    required ScannerConfiguration configuration,
    required ValueChanged<BarcodeScanResult> onScan,
  }) {
    _onScan = onScan;
    _focusNode = FocusNode();
    // ignore: void_checks
    return SynchronousFuture(1);
  }

  @override
  void dispose() {
    _focusNode.dispose();
  }

  @override
  ScannerProperties get properties => const ScannerProperties(
        supportedFormats: {
          BarcodeFormat.aztec,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.dataMatrix,
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.itf,
          BarcodeFormat.pdf417,
          BarcodeFormat.qr,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
        },
        hasUI: true,
      );

  @override
  late BarcodeScannerController controller;

  Timer? _debounceTimer;

  String externalScanString = '';

  static const debounceMillis = 50;

  void _onKeyEvent(KeyEvent event) {
    if (event.character != null && event.character!.isNotEmpty) {
      externalScanString += event.character!;
    }

    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: debounceMillis),
      () async {
        //trim spaces, tabs and `null` characters (\u0000)
        final finalScanString =
            externalScanString.trim().replaceAll('\u0000', '');
        externalScanString = '';
        _onScan(
          BarcodeScanResult(
            code: finalScanString,
            format: null,
            source: ScannerType.usbKeyboard,
          ),
        );
      },
    );
  }
}
