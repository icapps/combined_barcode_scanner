import 'dart:async';

import 'package:combined_barcode_scanner_unitech/src/scanner/scan_callback.dart';
import 'package:combined_barcode_scanner_unitech/src/scanner/unitech_scanner_interface.dart';

class UnitechScannerController {
  UnitechScannerCallBack? _scannerCallBack;

  set scannerCallBack(UnitechScannerCallBack scannerCallBack) => _scannerCallBack = scannerCallBack; // ignore: avoid_setters_without_getters

  StreamSubscription<String>? _subscription;

  UnitechScannerController();

  Future<bool> get isSupported => UnitechScannerInterface.isSupported;

  Future<bool> init() async {
    return Future.value(true);
  }

  Future<void> startScanning() async {
    _subscription ??= UnitechScannerInterface.events().listen((data) => _scannerCallBack?.onDecoded(data));
  }

  Future<void> stopScanning() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> triggerScan() => UnitechScannerInterface.startScanning();

  Future<bool> stopScan() => UnitechScannerInterface.startScanning();
}
