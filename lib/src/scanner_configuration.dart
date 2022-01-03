import 'package:flutter/foundation.dart';

@immutable
class ScannerConfiguration {
  final List<BarcodeFormat> enableFormats;
  final CameraConfiguration? cameraConfiguration;

  const ScannerConfiguration({
    required this.enableFormats,
    this.cameraConfiguration,
  });
}

@immutable
class CameraConfiguration {
  final CameraResolution resolution;
  final int frameRate;
  final BarcodeDetectionMode mode;
  final CameraType type;

  const CameraConfiguration({
    required this.resolution,
    required this.frameRate,
    required this.mode,
    required this.type,
  });
}

enum BarcodeDetectionMode {
  pauseDetection,
  pauseVideo,
  continuous,
}

enum CameraType { back, front }

enum BarcodeFormat {
  qr,
  aztec,
  codabar,
  code39,
  code93,
  code128,
  dataMatrix,
  ean8,
  ean13,
  itf,
  maxiCode,
  pdf417,
  rss14,
  rssExpanded,
  upcA,
  upcE,
  upcEanExtension,
}

enum CameraResolution {
  low,
  medium,
  hd,
  qhd,
}
