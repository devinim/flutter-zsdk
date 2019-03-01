import 'dart:async';

import 'package:flutter/services.dart';

class FlutterZsdk {
  static const MethodChannel _channel = const MethodChannel('flutter_zsdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Map<String, String>> discoverBluetoothDevices() async {
    dynamic d = await _channel.invokeMethod("discoverBluetoothDevices");
    return Map<String, String>.from(d);
  }

  static Future<Map<String, Map<String, String>>> getDeviceProperties(String mac) async {
    dynamic d = await _channel.invokeMethod("getDeviceProperties", {"mac": mac});
    Map<String, Map<String, String>> map = Map();

    d.foreach((k, v) {
      map[k] = Map<String, String>.from(v);
    });
    return map;
  }

  static Future<void> sendZplOverBluetooth(String mac, String data) async {
     await _channel.invokeMethod("sendZplOverBluetooth", {"mac": mac, "data": data});
  }
}
