import 'package:combined_barcode_scanner/src/scanner_configuration.dart';
import 'package:flutter/foundation.dart';

///Holds properties reported from the scanner that provides info for the UI.
///
/// This data class contains toMap/fromMap methods that return a map that is
/// safe to use in platform channels (or state restoration)
@immutable
class ScannerProperties {
  /// True if this scanner includes a UI component. If it does,
  /// [BarcodeScanner.buildUI] MUST NOT return null. If it is false,
  /// [BarcodeScanner.buildUI] will never be called
  final bool hasUI;

  /// The list of barcode formats supported by this scanner
  final Set<BarcodeFormat> supportedFormats;

  const ScannerProperties({
    required this.hasUI,
    required this.supportedFormats,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannerProperties &&
          runtimeType == other.runtimeType &&
          hasUI == other.hasUI &&
          setEquals(supportedFormats, other.supportedFormats);

  @override
  int get hashCode => hasUI.hashCode ^ supportedFormats.hashCode;

  @override
  String toString() {
    return 'ScannerProperties{hasUI: $hasUI, supportedFormats: $supportedFormats}';
  }

  Map<String, dynamic> toMap() {
    return {
      'hasUI': hasUI,
      'supportedFormats':
          supportedFormats.map((e) => e.index).toList(growable: false),
    };
  }

  factory ScannerProperties.fromMap(Map<String, dynamic> map) {
    return ScannerProperties(
      hasUI: map['hasUI'] as bool,
      supportedFormats: (map['supportedFormats'] as List)
          .cast<int>()
          .map((e) => BarcodeFormat.values[e])
          .toSet(),
    );
  }
}
