import 'dart:async';

import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:combined_barcode_scanner_zebra/src/zebra/scan_callback.dart';
import 'package:combined_barcode_scanner_zebra/src/zebra/zebra_datawedge_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';

/// Barcode scanner implementation that uses the zebra
/// hardware scanner where available.
///
/// Note that zebra devices use a profile to control the
/// properties of the scanner. This plugin will attempt
/// to create or update the profile with the provided
/// [profileName] to set the supported barcode formats.
///
/// Note: only a single zebra scanner can be active at
/// the same time
class ZebraBarcodeScanner implements BarcodeScanner {
  final _controller = ZebraDataWedgeController();
  var _supported = false;

  /// The name of the profile to activate (or create)
  final String profileName;

  @override
  late BarcodeScannerController controller;

  ZebraBarcodeScanner(this.profileName);

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
    if (_supported) {
      await _controller.init(profileName);
      _controller.scannerCallBack = _ScannerWrapper(onScan);
    }
    controller = _ZebraController(_controller, enabled: _supported)..start();
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
      BarcodeFormat.code128,
      BarcodeFormat.pdf417,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.qr,
      BarcodeFormat.aztec,
      BarcodeFormat.maxiCode,
    },
  );
}


class _ScannerWrapper implements ScannerCallBack {
  final ValueChanged<BarcodeScanResult> onScan;

  _ScannerWrapper(this.onScan);

  @override
  void onDecoded(ScanResult? result) {
    if (result != null) {
      onScan(
        BarcodeScanResult(
          code: result.data,
          format: _mapLabelType(result.labelType),
          source: ScannerType.zebra,
        ),
      );
    }
  }

  @override
  void onError(Exception error) {}
}

//https://techdocs.zebra.com/datawedge/15-0/guide/output/intent/
BarcodeFormat? _mapLabelType(String e) {
  switch (e) {
    case "LABEL-TYPE-QRCODE":
      return BarcodeFormat.qr;
    case "LABEL-TYPE-AZTEC":
      return BarcodeFormat.aztec;
    case "LABEL-TYPE-CODABAR":
      return BarcodeFormat.codabar;
    case "LABEL-TYPE-CODE39":
      return BarcodeFormat.code39;
    case "LABEL-TYPE-CODE93":
      return BarcodeFormat.code93;
    case "LABEL-TYPE-CODE128":
      return BarcodeFormat.code128;
    case "LABEL-TYPE-DATAMATRIX":
      return BarcodeFormat.dataMatrix;
    case "LABEL-TYPE-EAN8":
      return BarcodeFormat.ean8;
    case "LABEL-TYPE-EAN13":
      return BarcodeFormat.ean13;
    case "LABEL-TYPE-MAXICODE":
      return BarcodeFormat.maxiCode;
    case "LABEL-TYPE-PDF417":
      return BarcodeFormat.pdf417;
    case "LABEL-TYPE-UPCA":
      return BarcodeFormat.upcA;
    case "LABEL-TYPE-UPCE0":
    case "LABEL-TYPE-UPCE1":
      return BarcodeFormat.upcE;
    default:
      return null;
  }
}

class _ZebraController extends BarcodeScannerController {
  final ZebraDataWedgeController _scanner;
  final bool enabled;

  @override
  bool get isControllerSupported => enabled;

  _ZebraController(
    this._scanner, {
    required this.enabled,
  });

  @override
  dynamic get imei => _scanner.imei;

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

