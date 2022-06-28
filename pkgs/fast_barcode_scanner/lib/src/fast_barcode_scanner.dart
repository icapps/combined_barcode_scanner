import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:fast_barcode_scanner/fast_barcode_scanner.dart' as fbs;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Barcode scanner implementation that uses the fast_barcode_scanner library.
///
/// Please follow the installation instructions in
/// [https://pub.dev/packages/fast_barcode_scanner]
class FastBarcodeScanner implements BarcodeScanner {
  static const _defaultCameraConfig = CameraConfiguration(
    resolution: CameraResolution.medium,
    frameRate: 30,
    mode: BarcodeDetectionMode.pauseVideo,
    type: CameraType.back,
  );

  late ValueChanged<BarcodeScanResult> _onScan;

  @override
  Widget? buildUI(ScannerConfiguration configuration, BuildContext context) {
    final cameraConfig = configuration.cameraConfiguration ?? _defaultCameraConfig;
    return fbs.BarcodeCamera(
      types: _mapTypes(configuration.enableFormats),
      resolution: _mapResolution(cameraConfig.resolution),
      mode: _mapDetectionMode(cameraConfig.mode),
      position: _mapCameraPosition(cameraConfig.type),
      framerate: _mapFrameRate(cameraConfig.frameRate),
      onScan: (code) => _onScan(_mapBarcode(code)),
    );
  }

  @override
  Future<void> configure({
    required ScannerConfiguration configuration,
    required ValueChanged<BarcodeScanResult> onScan,
  }) {
    _onScan = onScan;
    controller = FastBarcodeScannerController();
    // ignore: void_checks
    return SynchronousFuture(1);
  }

  @override
  void dispose() {}

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
}

class FastBarcodeScannerController implements BarcodeScannerController {
  @override
  void pause() {
    fbs.CameraController.instance.pauseDetector();
  }

  @override
  void start() {
    fbs.CameraController.instance.resumeDetector();
  }
}

BarcodeScanResult _mapBarcode(fbs.Barcode code) {
  return BarcodeScanResult(
    code: code.value,
    format: _mapFastToType(code.type),
    source: ScannerType.fastBarcode,
  );
}

BarcodeFormat _mapFastToType(fbs.BarcodeType type) {
  switch (type) {
    case fbs.BarcodeType.aztec:
      return BarcodeFormat.aztec;
    case fbs.BarcodeType.code128:
      return BarcodeFormat.code128;
    case fbs.BarcodeType.code39:
      return BarcodeFormat.code39;
    case fbs.BarcodeType.codabar:
      return BarcodeFormat.codabar;
    case fbs.BarcodeType.dataMatrix:
      return BarcodeFormat.dataMatrix;
    case fbs.BarcodeType.ean13:
      return BarcodeFormat.ean13;
    case fbs.BarcodeType.ean8:
      return BarcodeFormat.ean8;
    case fbs.BarcodeType.itf:
      return BarcodeFormat.itf;
    case fbs.BarcodeType.pdf417:
      return BarcodeFormat.pdf417;
    case fbs.BarcodeType.qr:
      return BarcodeFormat.qr;
    case fbs.BarcodeType.upcA:
      return BarcodeFormat.upcA;
    case fbs.BarcodeType.upcE:
      return BarcodeFormat.upcE;
    default:
      throw ArgumentError('Unsupported barcode format scanned. Wrong configuration?!. Type: $type');
  }
}

fbs.Framerate _mapFrameRate(int frameRate) {
  if (frameRate <= 30) return fbs.Framerate.fps30;
  if (frameRate <= 60) return fbs.Framerate.fps60;
  if (frameRate <= 120) return fbs.Framerate.fps120;
  return fbs.Framerate.fps240;
}

fbs.CameraPosition _mapCameraPosition(CameraType type) {
  switch (type) {
    case CameraType.back:
      return fbs.CameraPosition.back;
    case CameraType.front:
      return fbs.CameraPosition.front;
  }
}

fbs.DetectionMode _mapDetectionMode(BarcodeDetectionMode mode) {
  switch (mode) {
    case BarcodeDetectionMode.pauseDetection:
      return fbs.DetectionMode.pauseDetection;
    case BarcodeDetectionMode.pauseVideo:
      return fbs.DetectionMode.pauseVideo;
    case BarcodeDetectionMode.continuous:
      return fbs.DetectionMode.continuous;
  }
}

fbs.Resolution _mapResolution(CameraResolution resolution) {
  switch (resolution) {
    case CameraResolution.low:
      return fbs.Resolution.sd480;
    case CameraResolution.medium:
      return fbs.Resolution.hd720;
    case CameraResolution.hd:
      return fbs.Resolution.hd1080;
    case CameraResolution.qhd:
      return fbs.Resolution.hd4k;
  }
}

List<fbs.BarcodeType> _mapTypes(Set<BarcodeFormat> enableFormats) {
  final types = <fbs.BarcodeType>[];
  for (final format in enableFormats) {
    switch (format) {
      case BarcodeFormat.qr:
        types.add(fbs.BarcodeType.qr);
        break;
      case BarcodeFormat.aztec:
        types.add(fbs.BarcodeType.aztec);
        break;
      case BarcodeFormat.codabar:
        types.add(fbs.BarcodeType.codabar);
        break;
      case BarcodeFormat.code39:
        types.add(fbs.BarcodeType.code39);
        break;
      case BarcodeFormat.code93:
        types.add(fbs.BarcodeType.code93);
        break;
      case BarcodeFormat.code128:
        types.add(fbs.BarcodeType.code128);
        break;
      case BarcodeFormat.dataMatrix:
        types.add(fbs.BarcodeType.dataMatrix);
        break;
      case BarcodeFormat.ean8:
        types.add(fbs.BarcodeType.ean8);
        break;
      case BarcodeFormat.ean13:
        types.add(fbs.BarcodeType.ean13);
        break;
      case BarcodeFormat.itf:
        types.add(fbs.BarcodeType.itf);
        break;
      case BarcodeFormat.pdf417:
        types.add(fbs.BarcodeType.pdf417);
        break;
      case BarcodeFormat.upcA:
        types.add(fbs.BarcodeType.upcA);
        break;
      case BarcodeFormat.upcE:
        types.add(fbs.BarcodeType.upcE);
        break;
      default:
        break; //Not supported
    }
  }
  return types;
}
