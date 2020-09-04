# go_flutter_plugin_serial

This Go package implements the host-side of the Flutter [go_flutter_plugin_serial](https://github.com/chenhuawei/go-flutter-plugin-serial) plugin.

## Usage

Import as:

```go
import go_flutter_plugin_serial "github.com/chenhuawei/go-flutter-plugin-serial/go"
```

Then add the following option to your go-flutter [application options](https://github.com/go-flutter-desktop/go-flutter/wiki/Plugin-info):

```go
flutter.AddPlugin(&go_flutter_plugin_serial.GoFlutterPluginSerialPlugin{}),
```


https://github.com/bradfordcp/macosxvirtualserialport
```shell
sudo socat -d -d -d -d -lf /tmp/socat \
  pty,link=/tmp/serial.master,raw,echo=0,user=chenhuawei,group=staff \
  pty,link=/tmp/serial.slave,raw,echo=0,user=chenhuawei,group=staff
```

```shell
 minicom -D /tmp/serial.master -b 9600
```
