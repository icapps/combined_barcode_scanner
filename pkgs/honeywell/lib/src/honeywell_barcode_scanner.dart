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
      _scanner.scannerCallBack = _ScannerWrapper(onScan);

      final properties = <String, dynamic>{
        ...CodeFormatUtils.getAsPropertiesComplement(_makeFormats(configuration.enableFormats)),
      };
      await _scanner.setProperties(properties);
    }
    controller = _HoneyWellController(_scanner, enabled: _supported);
  }

  @override
  void dispose() {
    if (_supported) {
      _scanner.scannerCallBack = _ScannerWrapper((_) {});
      _scanner.stopScanner();
    }
  }

  @override
  final ScannerProperties properties = const ScannerProperties(hasUI: false, supportedFormats: {
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

class _HoneyWellController implements BarcodeScannerController {
  final HoneywellScanner _scanner;
  final bool enabled;

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

class _ScannerWrapper implements ScannerCallBack {
  final ValueChanged<BarcodeScanResult> onScan;

  _ScannerWrapper(this.onScan);

  @override
  void onDecoded(String? result) {
    if (result != null) {
      onScan(BarcodeScanResult(code: result, format: null, source: ScannerType.honeywell));
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
