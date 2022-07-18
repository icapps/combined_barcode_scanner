import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test to-from map', () {
    test('Test ScannerProperties', () {
      const properties = ScannerProperties(hasUI: false, supportedFormats: {
        BarcodeFormat.qr,
        BarcodeFormat.aztec,
      });
      expect(ScannerProperties.fromMap(properties.toMap()), properties);
      _expectAllowedType(properties.toMap());

      const properties2 = ScannerProperties(hasUI: true, supportedFormats: {
        BarcodeFormat.ean8,
        BarcodeFormat.aztec,
      });
      expect(ScannerProperties.fromMap(properties2.toMap()), properties2);
      _expectAllowedType(properties2.toMap());
    });
    test('Test CameraConfiguration', () {
      const config = CameraConfiguration(
        resolution: CameraResolution.hd,
        frameRate: 40,
        type: CameraType.front,
        mode: BarcodeDetectionMode.continuous,
      );
      expect(CameraConfiguration.fromMap(config.toMap()), config);
      _expectAllowedType(config.toMap());

      const config2 = CameraConfiguration(
        resolution: CameraResolution.qhd,
        frameRate: 10,
        type: CameraType.back,
        mode: BarcodeDetectionMode.pauseDetection,
      );
      expect(CameraConfiguration.fromMap(config2.toMap()), config2);
      _expectAllowedType(config2.toMap());
    });
    test('Test ScannerConfiguration', () {
      const config = ScannerConfiguration(
        enableFormats: {BarcodeFormat.upcA},
        cameraConfiguration: CameraConfiguration(
          resolution: CameraResolution.hd,
          frameRate: 40,
          type: CameraType.front,
          mode: BarcodeDetectionMode.continuous,
        ),
      );
      expect(ScannerConfiguration.fromMap(config.toMap()), config);
      _expectAllowedType(config.toMap());

      const config2 = ScannerConfiguration(
        enableFormats: {BarcodeFormat.upcA},
        cameraConfiguration: null,
      );
      expect(ScannerConfiguration.fromMap(config2.toMap()), config2);
      _expectAllowedType(config2.toMap());
    });
    test('Test BarcodeScanResult', () {
      const result = BarcodeScanResult(
        code: '123',
        format: BarcodeFormat.upcA,
        source: ScannerType.unknown,
      );
      expect(BarcodeScanResult.fromMap(result.toMap()), result);
      _expectAllowedType(result.toMap());

      const result2 = BarcodeScanResult(
        code: '124',
        format: BarcodeFormat.qr,
        source: ScannerType.camera,
      );
      expect(BarcodeScanResult.fromMap(result2.toMap()), result2);
      _expectAllowedType(result2.toMap());

      const result3 = BarcodeScanResult(
        code: '124',
        format: null,
        source: ScannerType.unitech,
      );
      expect(BarcodeScanResult.fromMap(result3.toMap()), result3);
      _expectAllowedType(result3.toMap());
    });
  });
}

void _ensureSerializable(Map<String, dynamic> data) {
  for (final value in data.values) {
    _expectAllowedType(value);
  }
}

void _expectAllowedType(dynamic value) {
  if (value is int ||
      value is String ||
      value is bool ||
      value is double ||
      value == null) {
    //Ok
  } else if (value is Map) {
    _ensureSerializable(value as Map<String, dynamic>);
  } else if (value is List) {
    for (final element in value) {
      _expectAllowedType(element);
    }
  } else {
    expect(value.runtimeType, false, reason: 'Value is not serializable');
  }
}
