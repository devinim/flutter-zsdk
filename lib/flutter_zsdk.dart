import 'dart:async';

import 'package:flutter/services.dart';

class ZebraBluetoothDevice {
  final String mac;
  String friendlyName = "Unknown";

  ZebraBluetoothDevice(this.mac, this.friendlyName);

  Future<Map<String, Map<String, String>>> properties() => FlutterZsdk._getDeviceProperties(mac);

  Future<String> batteryLevel() async {
    return await FlutterZsdk._getBatteryLevel(mac);
  }

  Future<void> sendZplOverBluetooth(String data) => FlutterZsdk._sendZplOverBluetooth(mac, data);
}

class FlutterZsdk {
  static const MethodChannel _channel = const MethodChannel('flutter_zsdk');

  static Future<List<ZebraBluetoothDevice>> discoverBluetoothDevices() async {
    dynamic d = await _channel.invokeMethod("discoverBluetoothDevices");

    List<ZebraBluetoothDevice> devices = List();

    d.forEach((k, v) {
      devices.add(ZebraBluetoothDevice(k, v));
    });

    return devices;
  }

  static Future<Map<String, Map<String, String>>> _getDeviceProperties(String mac) async {
    dynamic d = await _channel.invokeMethod("getDeviceProperties", {"mac": mac});
    Map<String, Map<String, String>> map = Map();

    d.forEach((k, v) {
      map[k] = Map<String, String>.from(v);
    });
    return map;
  }

  static Future<String> _getBatteryLevel(String mac) async {
    dynamic d = await _channel.invokeMethod("getBatteryLevel", {"mac": mac});
    return d.toString();
  }

  static Future<void> _sendZplOverBluetooth(String mac, String data) async {
    await _channel.invokeMethod("sendZplOverBluetooth", {"mac": mac, "data": data});
  }
}
