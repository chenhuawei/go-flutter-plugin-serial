package go_flutter_plugin_serial

import (
	"errors"
	"fmt"
	"reflect"

	flutter "github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/go-flutter/plugin"
	"go.bug.st/serial"
)

const channelName = "go_flutter_plugin_serial"

// GoFlutterPluginSerialPlugin implements flutter.Plugin and handles method.
type GoFlutterPluginSerialPlugin struct {
	openedPorts map[string]serial.Port
}

var _ flutter.Plugin = &GoFlutterPluginSerialPlugin{} // compile-time type check

// InitPlugin initializes the plugin.
func (p *GoFlutterPluginSerialPlugin) InitPlugin(messenger plugin.BinaryMessenger) error {

	p.openedPorts = make(map[string]serial.Port)

	channel := plugin.NewMethodChannel(messenger, channelName, plugin.StandardMethodCodec{})
	channel.HandleFunc("getPlatformVersion", p.handlePlatformVersion)
	channel.HandleFunc("getSerialPortList", p.getSerialPortList)
	channel.HandleFunc("open", p.open)
	channel.HandleFunc("close", p.close)
	channel.HandleFunc("read", p.read)
	channel.HandleFunc("write", p.write)
	return nil
}

func (p *GoFlutterPluginSerialPlugin) handlePlatformVersion(arguments interface{}) (reply interface{}, err error) {
	return "go-flutter " + flutter.PlatformVersion, nil
}
func (p *GoFlutterPluginSerialPlugin) getSerialPortList(arguments interface{}) (reply interface{}, err error) {
	ports, err := serial.GetPortsList()
	if err != nil {
		return nil, err
	}
	var resultList []interface{}
	if len(ports) == 0 {
		fmt.Println("No serial ports found!")
	} else {
		//resultList = make([]interface{}, len(ports))
		for _, port := range ports {
			fmt.Printf("Found port: %v\n", port)
			resultList = append(resultList, port)
		}
	}
	return resultList, nil
}

func (p *GoFlutterPluginSerialPlugin) open(arguments interface{}) (reply interface{}, err error) {
	/*
		BaudRate: 9600,
		Parity:   serial.NoParity,
		DataBits: 8,
		StopBits: serial.OneStopBit,
	*/
	fmt.Printf("arguments %v, %T\n", arguments, reflect.TypeOf(arguments))

	args, ok := arguments.(map[interface{}]interface{})
	if !ok {
		return nil, errors.New("invalid param for option call")
	}
	var portName string
	var baudRate int32
	var parity int32
	var dataBits int32
	var stopBits int32

	portName = args["portName"].(string)

	if args["baudRate"] != nil {
		baudRate = args["baudRate"].(int32)
	}
	if args["parity"] != nil {
		parity = args["parity"].(int32)
	}
	if args["dataBits"] != nil {
		dataBits = args["dataBits"].(int32)
	}
	if args["stopBits"] != nil {
		stopBits = args["stopBits"].(int32)
	}
	fmt.Printf("open port: %v %v, %v, %v, %v\n", portName, baudRate, parity, dataBits, stopBits)

	mode := &serial.Mode{
		BaudRate: int(baudRate),
		Parity:   serial.Parity(parity),
		DataBits: int(dataBits),
		StopBits: serial.StopBits(stopBits),
	}
	fmt.Printf("mode: %v\n", mode)
	port := p.openedPorts[portName]
	if port != nil {
		if e := port.SetMode(mode); e != nil {
			return nil, e
		}
		return portName, nil
	}
	port, e := serial.Open(portName, mode)
	if e != nil {
		return nil, e
	}
	p.openedPorts[portName] = port
	return portName, nil
}

func (p *GoFlutterPluginSerialPlugin) write(arguments interface{}) (reply interface{}, err error) {
	args, ok := arguments.(map[interface{}]interface{})
	if !ok {
		return nil, errors.New("invalid param for option call")
	}
	portName := args["portName"].(string)
	data := args["data"].([]byte)
	port := p.openedPorts[portName]
	if port == nil {
		return nil, errors.New(portName + " not opened")
	}
	n, e := port.Write(data)
	if e != nil {
		return nil, e
	}
	return int32(n), nil
}

func (p *GoFlutterPluginSerialPlugin) close(arguments interface{}) (reply interface{}, err error) {
	args, ok := arguments.(map[interface{}]interface{})
	if !ok {
		return nil, errors.New("invalid param for option call")
	}
	portName := args["portName"].(string)

	port := p.openedPorts[portName]
	if port == nil {
		return nil, errors.New(portName + " not opened")
	}
	e := port.Close()
	if e != nil {
		return nil, e
	}
	return nil, nil
}

func (p *GoFlutterPluginSerialPlugin) read(arguments interface{}) (reply interface{}, err error) {
	args, ok := arguments.(map[interface{}]interface{})
	if !ok {
		return nil, errors.New("invalid param for option call")
	}
	portName := args["portName"].(string)

	port := p.openedPorts[portName]
	if port == nil {
		return nil, errors.New(portName + " not opened")
	}
	buff := make([]byte, 128)
	n, e := port.Read(buff)
	if e != nil {
		return nil, e
	}
	if n == 0 {
		return nil, nil
	}
	fmt.Printf("read: %v bytes\n", n)
	result := make([]byte, n)
	copy(result[:], buff[:n])
	return result, nil
}
