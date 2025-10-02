import 'package:flutter_datawedge/flutter_datawedge.dart';

abstract class ScannerCallBack {
  void onDecoded(ScanResult? result);

  void onError(Exception error);
}
