import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UnitechScannerInterface {
  static const MethodChannel _channel = MethodChannel('unitech_scanner');

  static EventChannel? _eventChannel;

  static Future<bool> get isSupported async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('isSupported') == true;
  }

  static Stream<String> events() {
    final channel =
        _eventChannel ??= const EventChannel('unitech_scanner/scan');
    return channel.receiveBroadcastStream().map((dynamic e) => e.toString());
  }

  static Future<bool> startScanning() async {
    return await _channel.invokeMethod<bool>('startScan') == true;
  }

  static Future<bool> stopScanning() async {
    return await _channel.invokeMethod<bool>('stopScan') == true;
  }
}
