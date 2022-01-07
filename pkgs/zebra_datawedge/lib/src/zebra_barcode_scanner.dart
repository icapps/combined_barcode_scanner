import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:combined_barcode_scanner_zebra/src/zebra/scan_callback.dart';
import 'package:combined_barcode_scanner_zebra/src/zebra/zebra_datawedge_controller.dart';
import 'package:combined_barcode_scanner_zebra/src/zebra/zebra_interface.dart';
import 'package:flutter/widgets.dart';

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
    _supported = await _controller.isSupported;
    await _controller.init(profileName, _mapFormats(configuration.enableFormats));

    _controller.scannerCallBack = _ScannerWrapper(onScan);
    controller = _ZebraController(_controller, enabled: _supported);
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

List<String> _mapFormats(Set<BarcodeFormat> enableFormats) {
  return enableFormats.mapNotNull(_mapFormat).toList();
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

class _ZebraController implements BarcodeScannerController {
  final ZebraDataWedgeController _scanner;
  final bool enabled;

  _ZebraController(
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

String? _mapFormat(BarcodeFormat e) {
  switch (e){
    case BarcodeFormat.qr: return QRCODE;
    case BarcodeFormat.aztec: return AZTEC;
    case BarcodeFormat.codabar: return CODEBAR;
    case BarcodeFormat.code39: return CODE39;
    case BarcodeFormat.code93: return CODE93;
    case BarcodeFormat.code128: return CODE128;
    case BarcodeFormat.dataMatrix: return DATAMATRIX;
    case BarcodeFormat.ean8: return EAN8;
    case BarcodeFormat.ean13: return EAN13;
    case BarcodeFormat.maxiCode: return MAXICODE;
    case BarcodeFormat.pdf417: return PDF417;
    case BarcodeFormat.upcA: return UPCA;
    case BarcodeFormat.upcE: return UPCE0;
    default: return null;
  }
}

extension _IterableExt<T> on Iterable<T> {
  Iterable<R> mapNotNull<R>(R? Function(T) mapper) {
    final res = <R>[];
    forEach((element) {
      final mapped = mapper(element);
      if (mapped != null) {
        res.add(mapped);
      }
    });
    return res;
  }
}