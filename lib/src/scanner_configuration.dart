import 'package:flutter/foundation.dart';

/// Holds scanner configuration data. Contains both generic configuration data
/// such as which formats are supported as well as optional camera configuration
/// for scanners that use the camera. The camera data is provided as a hint, the
/// actual implementation can choose alternatives and/or reasonable defaults.
///
/// This data class contains toMap/fromMap methods that return a map that is
/// safe to use in platform channels (or state restoration)
@immutable
class ScannerConfiguration {
  /// The list of enabled bar code formats. Formats outside this range SHOULD NOT
  /// be reported by the scanner in the callback
  final Set<BarcodeFormat> enableFormats;

  /// Optional camera configuration object. This data is provided as a hint
  /// to the actual scanner and implementations can choose alternatives and/or
  /// reasonable defaults.
  final CameraConfiguration? cameraConfiguration;

  const ScannerConfiguration({
    required this.enableFormats,
    this.cameraConfiguration,
  });

  @override
  String toString() {
    return 'ScannerConfiguration{enableFormats: $enableFormats, cameraConfiguration: $cameraConfiguration}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannerConfiguration &&
          runtimeType == other.runtimeType &&
          setEquals(enableFormats, other.enableFormats) &&
          cameraConfiguration == other.cameraConfiguration;

  @override
  int get hashCode => enableFormats.hashCode ^ cameraConfiguration.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'enableFormats':
          enableFormats.map((e) => e.index).toList(growable: false),
      'cameraConfiguration': cameraConfiguration?.toMap(),
    };
  }

  factory ScannerConfiguration.fromMap(Map<String, dynamic> map) {
    final camMap =
        (map['cameraConfiguration'] as Map?)?.cast<String, dynamic>();
    final camConfig =
        camMap != null ? CameraConfiguration.fromMap(camMap) : null;

    return ScannerConfiguration(
      enableFormats: (map['enableFormats'] as List)
          .cast<int>()
          .map((e) => BarcodeFormat.values[e])
          .toSet(),
      cameraConfiguration: camConfig,
    );
  }
}

/// Configuration container for the device camera. All values here are hints to the
/// underlying implementation.
///
/// This data class contains toMap/fromMap methods that return a map that is
/// safe to use in platform channels (or state restoration)
@immutable
class CameraConfiguration {
  /// The requested camera resolution (higher could mean slower scans)
  final CameraResolution resolution;

  /// The requested frame rate
  final int frameRate;

  /// The detection mode of the scanner
  final BarcodeDetectionMode mode;

  /// The camera type to use
  final CameraType type;

  const CameraConfiguration({
    required this.resolution,
    required this.frameRate,
    required this.mode,
    required this.type,
  });

  @override
  String toString() {
    return 'CameraConfiguration{resolution: $resolution, frameRate: $frameRate, mode: $mode, type: $type}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraConfiguration &&
          runtimeType == other.runtimeType &&
          resolution == other.resolution &&
          frameRate == other.frameRate &&
          mode == other.mode &&
          type == other.type;

  @override
  int get hashCode =>
      resolution.hashCode ^ frameRate.hashCode ^ mode.hashCode ^ type.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'resolution': resolution.index,
      'frameRate': frameRate,
      'mode': mode.index,
      'type': type.index,
    };
  }

  factory CameraConfiguration.fromMap(Map<String, dynamic> map) {
    return CameraConfiguration(
      resolution: CameraResolution.values[map['resolution'] as int],
      frameRate: map['frameRate'] as int,
      mode: BarcodeDetectionMode.values[map['mode'] as int],
      type: CameraType.values[map['type'] as int],
    );
  }
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
