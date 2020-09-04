import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_flutter_plugin_serial/go_flutter_plugin_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<String> portNames = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GoFlutterPluginSerial.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      List ports = await GoFlutterPluginSerial.serialPortList;
      print('ports $ports');
      ports.forEach((element) {
        this.portNames.add(element);
      });
      setState(() {
        this.loading = false;
      });
    } catch(err) {
      print('get serial port list error: $err');
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: loading ? CircularProgressIndicator() : ListView(
            children: buildPortList(),
          ),
        ),
      ),
    );
  }
  void connect(portName) {
    SerialMode mode = SerialMode(baudRate: 9600);
    GoFlutterPluginSerial.open(portName, mode: mode).then((session) {
      print('session $session');
      List<int> list = utf8.encode("hello world\r\n");
      print('write $list');
      session.write(Uint8List.fromList(list));

      session.read().then((value) => print('read: $value'));
    });
  }
  List<Widget> buildPortList() {
    List<Widget> widgets = [];
    widgets.add(ListTile(leading: Icon(Icons.device_unknown), 
      title: TextButton(child: Text('/tmp/serial.master'), 
      onPressed: () => connect('/tmp/serial.master'),),));

    this.portNames.forEach((element) {
      
      widgets.add(ListTile(leading: Icon(Icons.device_unknown), title: TextButton(child: Text(element), onPressed: () => connect(element),),));
    });
    return widgets;
  }
}
