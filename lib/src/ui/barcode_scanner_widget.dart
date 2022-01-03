import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:combined_barcode_scanner/src/barcode_scanner.dart';
import 'package:flutter/material.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final ValueChanged<String> onScan;
  final ScannerConfiguration configuration;
  final List<BarcodeScanner> scanners;

  const BarcodeScannerWidget({
    required this.onScan,
    required this.configuration,
    required this.scanners,
    Key? key,
  }) : super(key: key);

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final configuredScanners = <BarcodeScanner?>[];

  @override
  void initState() {
    super.initState();

    var c = 0;
    for (final scanner in widget.scanners) {
      final index = c++;
      scanner.configure(configuration: widget.configuration, onScan: widget.onScan).then((_) {
        if (mounted) {
          configuredScanners[index] = scanner;
          setState(() {});
        } else {
          scanner.dispose();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final scanner in configuredScanners) {
      scanner?.dispose();
    }
    configuredScanners.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: configuredScanners.map((e) => e?.properties.hasUI == true ? e!.buildUI(widget.configuration, context)! : const SizedBox()).toList(),
    );
  }
}
