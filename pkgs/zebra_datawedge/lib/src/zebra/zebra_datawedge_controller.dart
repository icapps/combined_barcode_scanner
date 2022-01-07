import 'dart:async';
import 'dart:io';

import 'package:combined_barcode_scanner_zebra/src/zebra/scan_callback.dart';
import 'package:combined_barcode_scanner_zebra/src/zebra/zebra_interface.dart';
import 'package:flutter/foundation.dart';

class ZebraDataWedgeController {
  ScannerCallBack? _scannerCallBack;

  set scannerCallBack(ScannerCallBack scannerCallBack) => _scannerCallBack = scannerCallBack; // ignore: avoid_setters_without_getters

  void setScannerCallBack(ScannerCallBack scannerCallBack) => this.scannerCallBack = scannerCallBack; // ignore: use_setters_to_change_properties

  StreamSubscription<String>? _subscription;

  ZebraDataWedgeController();

  Future<bool> get isSupported async => (!kIsWeb && Platform.isAndroid) && await ZebraInterface.isSupported;

  Future<bool> init(String profileName, List<String> supportedFormats) async {
    if (!(await ZebraInterface.profiles).contains(profileName)) {
      return ZebraInterface.createProfile(profileName, supportedFormats);
    } else {
      return ZebraInterface.updateProfile(profileName, supportedFormats);
    }
  }

  Future<void> startScanning() async {
    _subscription ??= ZebraInterface.events().listen((data) => _scannerCallBack?.onDecoded(data));
  }

  Future<void> stopScanning() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> triggerScan() => ZebraInterface.startScanning();
}
