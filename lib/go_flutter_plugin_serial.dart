// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class GoFlutterPluginSerial {
  static const MethodChannel _channel =
      const MethodChannel('go_flutter_plugin_serial');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List> get serialPortList async {
    List list = await _channel.invokeListMethod('getSerialPortList');
    return list;
  }

  static Future<SerialSession> open(String portName, {SerialMode mode}) async {
    if (mode == null) {
      mode = SerialMode();
    }
    await _channel.invokeMethod('open', {
      "portName": portName,
      "baudRate": mode.baudRate,
      "parity": mode.parity,
      "dataBits": mode.dataBits,
      "stopBits": mode.stopBits
      });

    return SerialSession(portName);
  }

   
}
class SerialSession {
  final String portName;
  
  SerialSession(this.portName);

  Future<int> write(Uint8List bytes) async {
    var result =  await GoFlutterPluginSerial._channel.invokeMethod('write', {
      'portName': this.portName,
      'data': bytes
    });
    print("write $result bytes");
    return result;
  }

  Future<Uint8List> read([int len=0]) async {
    var result = await GoFlutterPluginSerial._channel.invokeMethod('read', {
      'portName': this.portName,
      'len': len
    });
    print('read $result bytes');
    return result;
  }

  Future<int> close() async {

    return await GoFlutterPluginSerial._channel.invokeMethod('close');
  }

}
class SerialMode {
  int baudRate;
  int dataBits;
  int parity;
  int stopBits;

  SerialMode({this.baudRate=38400, this.dataBits=8, this.parity=0, this.stopBits=0});
}