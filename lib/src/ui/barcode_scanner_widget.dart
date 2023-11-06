import 'dart:async';

import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icapps_torch_compat/icapps_torch_compat.dart';

typedef BoolCallback = bool Function();
typedef BoolCallbackWithType = bool Function<T extends BarcodeScanner>();
typedef AsyncBoolCallback = Future<bool> Function();

/// Controller used to control the scanner widget
class BarcodeScannerWidgetController {
  /// Called when all passed scanners have been configured
  VoidCallback? onScannersConfigured;
  VoidCallback? _onStartListener;
  VoidCallback? _onEndListener;
  BoolCallback? _onIsTorchOnListener;
  AsyncCallback? _onToggleTorchListener;
  AsyncCallback? _onToggleCameraListener;
  AsyncBoolCallback? _onSupportsSwitchingCameraListener;
  BoolCallbackWithType? _onSupportScannerListener;

  BarcodeScannerWidgetController([this.onScannersConfigured]);

  /// Call this to (re-)start the scanners
  void start() => _onStartListener?.call();

  /// Call this to pause the scanners
  void pause() => _onEndListener?.call();

  /// Whether the device can switch between cameras (for example front vs back)
  Future<bool> get supportsSwitchingCamera async =>
      await _onSupportsSwitchingCameraListener?.call() ?? false;

  /// Whether the device can switch torch on/off
  Future<bool> get supportsSwitchingTorch async =>
      await TorchCompat.hasTorch ?? false;

  /// Whether the device has a torch that is on
  bool get isTorchOn => _onIsTorchOnListener?.call() ?? false;

  /// Switch between cameras (if supported. see [supportsSwitchingCamera])
  Future<void> toggleCamera() async => _onToggleCameraListener?.call();

  /// Switch the torch on/off (see [isTorchOn] for current state)
  Future<void> toggleTorch() async => _onToggleTorchListener?.call();

  /// Whether the scanner type is supported
  bool supportsScanner<T extends BarcodeScanner>() =>
      _onSupportScannerListener?.call<T>() ?? false;

  /// Call this to dispose the controller
  void dispose() {
    onScannersConfigured = null;
    _clearListeners();
  }

  void _clearListeners() {
    _onStartListener = null;
    _onEndListener = null;
    _onSupportsSwitchingCameraListener = null;
    _onIsTorchOnListener = null;
    _onToggleCameraListener = null;
    _onToggleTorchListener = null;
    _onSupportScannerListener = null;
  }
}

/// Widget that combines multiple scanners
class BarcodeScannerWidget extends StatefulWidget {
  /// Callback invoked when a code is scanned
  final ValueChanged<BarcodeScanResult> onScan;

  /// The configuration of the scanners
  final ScannerConfiguration configuration;

  /// The list of scanners to configure/use
  final List<BarcodeScanner> scanners;

  /// The controller for this scanner
  final BarcodeScannerWidgetController controller;

  const BarcodeScannerWidget({
    required this.onScan,
    required this.configuration,
    required this.scanners,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();

  void _onScan(BarcodeScanResult code) {
    if (configuration.trimWhiteSpaces) {
      onScan(BarcodeScanResult(
        code: code.code.trim(),
        format: code.format,
        source: code.source,
      ));
    } else {
      onScan(code);
    }
  }
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final _configuredScanners = <BarcodeScanner?>[];
  var _configureCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();
    _setListeners();
    _buildScanners();
  }

  void _setListeners() => widget.controller
    .._onStartListener = _startCalled
    .._onEndListener = _endCalled
    .._onSupportsSwitchingCameraListener = _onSupportsSwitchingCameraListener
    .._onIsTorchOnListener = _onIsTorchOnListener
    .._onToggleCameraListener = _onToggleCameraListener
    .._onToggleTorchListener = _onToggleTorchListener
    .._onSupportScannerListener = _onSupportScannerListener;

  @override
  void didUpdateWidget(BarcodeScannerWidget oldWidget) {
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller._clearListeners();
      widget.controller
        .._onStartListener = _startCalled
        .._onStartListener = _endCalled;
    }
    // If the configuration changes, we need to rebuild all scanners.
    // Wait for the previous configuration to finish first before calling
    // dispose
    if (!listEquals(widget.scanners, oldWidget.scanners) ||
        widget.configuration != oldWidget.configuration) {
      _configureCompleter.future.then((_) {
        _configureCompleter = Completer<void>();
        for (final scanner in _configuredScanners) {
          scanner?.dispose();
        }
        _configuredScanners.clear();
        _buildScanners();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // Wait for the previous configuration to finish before calling dispose
    _configureCompleter.future.then((_) {
      for (final scanner in _configuredScanners) {
        scanner?.dispose();
      }
      _configuredScanners.clear();
    });
    widget.controller._clearListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _configuredScanners
          .map((e) => e?.properties.hasUI == true
              ? e!.buildUI(widget.configuration, context)!
              : const SizedBox())
          .toList(),
    );
  }

  void _startCalled() {
    for (final value in _configuredScanners) {
      value?.controller.start();
    }
  }

  void _endCalled() {
    for (final value in _configuredScanners) {
      value?.controller.pause();
    }
  }

  Future<bool> _onSupportsSwitchingCameraListener() async {
    for (final value in _configuredScanners) {
      if (await value?.controller.supportsSwitchingCamera ?? false) return true;
    }
    return false;
  }

  bool _onIsTorchOnListener() => _configuredScanners
      .any((element) => element?.controller.isTorchOn ?? false);

  Future<void> _onToggleCameraListener() async {
    for (final value in _configuredScanners) {
      if (await value?.controller.supportsSwitchingCamera ?? false) {
        await value?.controller.toggleCamera();
        return;
      }
    }
  }

  bool _onSupportScannerListener<T extends BarcodeScanner>() {
    return _configuredScanners
        .whereType<T>()
        .any((element) => element.controller.isControllerSupported);
  }

  Future<void> _onToggleTorchListener() async {
    for (final value in _configuredScanners) {
      final controller = value?.controller;
      if (controller == null) continue;
      final state = controller.isTorchOn;
      await controller.toggleTorch();
      if (state != controller.isTorchOn) return;
    }
  }

  void _buildScanners() {
    _configuredScanners.clear();
    _configuredScanners.length = widget.scanners.length;
    _configuredScanners.fillRange(0, _configuredScanners.length, null);
    setState(() {});

    var c = 0;
    var completed = 0;
    for (final scanner in widget.scanners) {
      final index = c++;
      scanner
          .configure(
              configuration: widget.configuration, onScan: widget._onScan)
          .then((_) {
        ++completed;
        if (mounted) {
          _configuredScanners[index] = scanner;
          setState(() {});
        } else {
          scanner.dispose();
        }
      }).catchError((dynamic e) {
        ++completed;
      }).then((_) {
        if (completed == widget.scanners.length) {
          _configureCompleter.complete();
          if (mounted) {
            widget.controller.onScannersConfigured?.call();
          }
        }
      });
    }
  }
}
