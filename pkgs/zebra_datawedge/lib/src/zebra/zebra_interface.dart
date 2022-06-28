// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/services.dart';

class ZebraInterface {
  static const MethodChannel _channel = MethodChannel('zebra');

  static EventChannel? _eventChannel;

  static Future<bool> get isControllerSupported async {
    return await _channel.invokeMethod<bool>('isControllerSupported') == true;
  }

  static Future<List<String>> get profiles async {
    final version = await _channel.invokeMethod<List<Object?>>('getProfiles');
    return version?.map((e) => e.toString()).toList() ?? [];
  }

  static Future<bool> createProfile(
      String name, List<String> supportedBarcodes) async {
    return await _channel.invokeMethod<bool>('createProfile', <String, dynamic>{
          'profileName': name,
          'formats': supportedBarcodes
        }) ==
        true;
  }

  static Future<bool> updateProfile(
      String name, List<String> supportedBarcodes) async {
    try {
      return await _channel.invokeMethod<bool>(
              'updateProfile', <String, dynamic>{
            'profileName': name,
            'formats': supportedBarcodes
          }) ==
          true;
    } catch (e) {
      return false;
    }
  }

  static Stream<String> events() {
    final channel = _eventChannel ??= const EventChannel('zebra/scan');
    return channel.receiveBroadcastStream().map((dynamic e) => e.toString());
  }

  static Future<bool> startScanning() async {
    return await _channel.invokeMethod<bool>('startScan') == true;
  }

  static Future<bool> stopScanning() async {
    return await _channel.invokeMethod<bool>('stopScan') == true;
  }
}

const AUSTRALIAN_POSTAL = "decoder_australian_postal";
const AZTEC = "decoder_aztec";
const CANADIAN_POSTAL = "decoder_canadian_postal";
const CHINESE2OF5 = "decoder_chinese_2of5";
const CODE11 = "decoder_code11";
const CODE128 = "decoder_code128";
const CODE39 = "decoder_code39";
const CODE93 = "decoder_code93";
const CODEBAR = "decoder_codabar";
const COMPOSITE_AB = "decoder_composite_ab";
const COMPOSITE_C = "decoder_composite_c";
const D2OF5 = "decoder_d2of5";
const DATAMATRIX = "decoder_datamatrix";
const DUTCH_POSTAL = "decoder_dutch_postal";
const EAN13 = "decoder_ean13";
const EAN8 = "decoder_ean8";
const GS1_DATABAR = "decoder_gs1_databar";
const GS1_DATAMATRIX = "decoder_gs1_datamatrix";
const GS1_LIM_SECURITY_LEVEL = "decoder_gs1_lim_security_level";
const GS1_QRCODE = "decoder_gs1_qrcode";
const HANXIN = "decoder_hanxin";
const I2OF5 = "decoder_i2of5";
const I2OF5_CHECK_DIGIT = "decoder_i2of5_check_digit";
const I2OF5_CONVERT_TO_EAN13 = "decoder_i2of5_convert_to_ean13";
const I2OF5_REDUNDANCY = "decoder_i2of5_redundancy";
const I2OF5_REPORT_CHECK_DIGIT = "decoder_i2of5_report_check_digit";
const I2OF5_SECURITY_LEVEL = "decoder_i2of5_security_level";
const JAPANESE_POSTAL = "decoder_japanese_postal";
const KOREAN3OF5 = "decoder_korean_3of5";
const MAILMARK = "decoder_mailmark";
const MATRIX_2OF5 = "decoder_matrix_2of5";
const MATRIX_2OF5_REDUNDANCY = "decoder_matrix_2of5_redundancy";
const MATRIX_2OF5_REPORT_CHECK_DIGIT = "decoder_matrix_2of5_report_check_digit";
const MATRIX_2OF5_VERIFY_CHECK_DIGIT = "decoder_matrix_2of5_verify_check_digit";
const MAXICODE = "decoder_maxicode";
const MICROPDF = "decoder_micropdf";
const MICROQR = "decoder_microqr";
const MSI = "decoder_msi";
const PDF417 = "decoder_pdf417";
const QRCODE = "decoder_qrcode";
const SIGNATURE = "decoder_signature";
const TLC39 = "decoder_tlc39";
const TRIOPTIC39 = "decoder_trioptic39";
const UK_POSTAL = "decoder_uk_postal";
const UPCA = "decoder_upca";
const UPCE0 = "decoder_upce0";
const UPCE1 = "decoder_upce1";
const US4STATE = "decoder_us4state";
const USPLANET = "decoder_usplanet";
const USPOSTNET = "decoder_uspostnet";
const WEBCODE = "decoder_webcode";
