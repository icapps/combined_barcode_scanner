import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';

/// Barcode scanner implementation that uses the honeywell
/// hardware scanner where available.
///
/// Please follow the installation instructions in
/// [https://pub.dev/packages/honeywell_scanner]
///
/// Note: only a single honeywell scanner can be active at
/// the same time
class HoneywellBarcodeScanner implements BarcodeScanner {
  final _scanner = HoneywellScanner();
  var _supported = false;

  @override
  late BarcodeScannerController controller;

  @override
  Widget? buildUI(ScannerConfiguration configuration, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Future<void> configure({
    required ScannerConfiguration configuration,
    required ValueChanged<BarcodeScanResult> onScan,
  }) async {
    _supported = await _scanner.isSupported();
    if (_supported) {
      _scanner.setScannerCallback(_ScannerWrapper(onScan));

      final properties = <String, dynamic>{
        ...CodeFormatUtils.getAsPropertiesComplement(
            _makeFormats(configuration.enableFormats)),
      };
      await _scanner.setProperties(properties);
    }
    controller = _HoneyWellController(_scanner, enabled: _supported);
  }

  @override
  void dispose() {
    if (_supported) {
      _scanner.stopScanner();
      _scanner.disposeScanner();
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

class _HoneyWellController extends BarcodeScannerController {
  final HoneywellScanner _scanner;
  final bool enabled;

  @override
  bool get isControllerSupported => enabled;

  _HoneyWellController(
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

List<CodeFormat> _makeFormats(Set<BarcodeFormat> enableFormats) {
  return enableFormats.mapNotNull(_mapFormat).toList();
}

class _ScannerWrapper implements ScannerCallback {
  final ValueChanged<BarcodeScanResult> onScan;

  _ScannerWrapper(this.onScan);

  @override
  void onDecoded(ScannedData? scannedData) {
    if (scannedData != null && scannedData.code != null) {
      onScan(
        BarcodeScanResult(
          code: scannedData.code!,
          format: _mapCodeId(scannedData.codeId),
          source: ScannerType.honeywell,
        ),
      );
    }
  }

  @override
  void onError(Exception error) {}
}

CodeFormat? _mapFormat(BarcodeFormat e) {
  switch (e) {
    case BarcodeFormat.qr:
      return CodeFormat.QR_CODE;
    case BarcodeFormat.aztec:
      return CodeFormat.AZTEC;
    case BarcodeFormat.codabar:
      return CodeFormat.CODABAR;
    case BarcodeFormat.code39:
      return CodeFormat.CODE_39;
    case BarcodeFormat.code93:
      return CodeFormat.CODE_93;
    case BarcodeFormat.code128:
      return CodeFormat.CODE_128;
    case BarcodeFormat.dataMatrix:
      return CodeFormat.DATA_MATRIX;
    case BarcodeFormat.ean8:
      return CodeFormat.EAN_8;
    case BarcodeFormat.ean13:
      return CodeFormat.EAN_13;
    case BarcodeFormat.maxiCode:
      return CodeFormat.MAXICODE;
    case BarcodeFormat.pdf417:
      return CodeFormat.PDF_417;
    case BarcodeFormat.rss14:
      return CodeFormat.RSS_14;
    case BarcodeFormat.rssExpanded:
      return CodeFormat.RSS_EXPANDED;
    case BarcodeFormat.upcA:
      return CodeFormat.UPC_A;
    case BarcodeFormat.upcE:
      return CodeFormat.UPC_E;
    default:
      return null;
  }
}

//https://sps-support.honeywell.com/s/article/List-of-Honeywell-barcode-symbology-Code-Identifiers
BarcodeFormat? _mapCodeId(String? codeId) {
  switch (codeId) {
    case "s":
      return BarcodeFormat.qr;
    case "z":
      return BarcodeFormat.aztec;
    case "a":
      return BarcodeFormat.codabar;
    case "b":
      return BarcodeFormat.code39;
    case "i":
      return BarcodeFormat.code93;
    case "j":
      return BarcodeFormat.code128;
    case "w":
      return BarcodeFormat.dataMatrix;
    case "D":
      return BarcodeFormat.ean8;
    case "d":
      return BarcodeFormat.ean13;
    case "x":
      return BarcodeFormat.maxiCode;
    case "r":
      return BarcodeFormat.pdf417;
    case "c":
      return BarcodeFormat.upcA;
    case "E":
      return BarcodeFormat.upcE;
    default:
      return null;
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
