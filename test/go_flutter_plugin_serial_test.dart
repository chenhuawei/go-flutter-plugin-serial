import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_flutter_plugin_serial/go_flutter_plugin_serial.dart';

void main() {
  const MethodChannel channel = MethodChannel('go_flutter_plugin_serial');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await GoFlutterPluginSerial.platformVersion, '42');
  });
}
