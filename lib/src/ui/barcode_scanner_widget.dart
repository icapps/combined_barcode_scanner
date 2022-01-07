import 'dart:async';

import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Controller used to control the scanner widget
class BarcodeScannerWidgetController {
  /// Called when all passed scanners have been configured
  final VoidCallback onScannersConfigured;
  VoidCallback? _onStartListener;
  VoidCallback? _onEndListener;

  BarcodeScannerWidgetController(this.onScannersConfigured);

  /// Call this to (re-)start the scanners
  void start() {
    _onStartListener?.call();
  }

  /// Call this to pause the scanners
  void pause() {
    _onEndListener?.call();
  }

  /// Call this to dispose the controller
  void dispose() {
    _onStartListener = null;
    _onEndListener = null;
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
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final _configuredScanners = <BarcodeScanner?>[];
  var _configureCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();

    widget.controller
      .._onStartListener = _startCalled
      .._onStartListener = _endCalled;

    _buildScanners();
  }

  @override
  void didUpdateWidget(BarcodeScannerWidget oldWidget) {
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller
        .._onStartListener = null
        .._onEndListener = null;

      widget.controller
        .._onStartListener = _startCalled
        .._onStartListener = _endCalled;
    }

    // If the configuration changes, we need to rebuild all scanners.
    // Wait for the previous configuration to finish first before calling
    // dispose
    if (!listEquals(widget.scanners, oldWidget.scanners) || widget.configuration != oldWidget.configuration) {
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _configuredScanners.map((e) => e?.properties.hasUI == true ? e!.buildUI(widget.configuration, context)! : const SizedBox()).toList(),
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

  void _buildScanners() {
    _configuredScanners.clear();
    _configuredScanners.length = widget.scanners.length;
    _configuredScanners.fillRange(0, _configuredScanners.length, null);
    setState(() {});

    var c = 0;
    var completed = 0;
    for (final scanner in widget.scanners) {
      final index = c++;
      scanner.configure(configuration: widget.configuration, onScan: widget.onScan).then((_) {
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
            widget.controller.onScannersConfigured();
          }
        }
      });
    }
  }
}
