import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Print',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Test Print'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.android.bluetooth');
  // PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<BluetoothDevice> _devices = [];
  String? _devicesMsg;
  // final BluetoothManager bluetoothManager = BluetoothManager.instance;
  String? _testString;
  String? _macAddress;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _initBluetooth();
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      form.reset();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      _macString();
      Map print = <String, dynamic>{"print": _testString};
      if (_macAddress != null) {
        Map address = <String, dynamic>{"mac": _macAddress};
        adapter(address, print);
      }
    } else {
      showNoPrinterDialog3('input text');
    }
  }

  // Initialize the Bluetooth connection
  Future<void> _initBluetooth() async {
    // Check if Bluetooth is enabled
    bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    if (isEnabled == false) {
      // If Bluetooth is not enabled, request permission to enable it
      bool? success = await FlutterBluetoothSerial.instance.requestEnable();
      if (success == false) {
        // If the user denies the request to enable Bluetooth, show an error message
        showNoPermissionBluetoothDialog();
        return;
      }
    }

    showBluetoothDialog();
    // Start scanning for available paired Bluetooth devices
    final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _macString() async {
    if (_devices.isNotEmpty) {
      final macad = _devices.first.address;
      setState(() {
        _macAddress = macad;
      });
    }
  }

  Future<void> showNoPermissionBluetoothDialog() async => showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => AlertDialog(
          title: const Text('No Bluetooth permission '),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please enable Bluetooth and try again.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Acknowledge'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

  Future<void> showBluetoothDialog() async => showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Open settings and connect to a printer '),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Connect to a printer'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('connect'),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

  Future<void> showNoPrinterDialog2(String e) async => showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => AlertDialog(
          title: const Text('No printer connected '),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(e),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Acknowledge'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

  Future<void> showNoPrinterDialog3(String e) async => showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Empty text'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(e),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Acknowledge'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

  Future<void> adapter(Map mapMac, Map mapPrint) async {
    String? bluetoothAdapter;
    try {
      bluetoothAdapter =
          await platform.invokeMethod('adapterone', [mapMac, mapPrint]);
      setState(() {
        _devicesMsg = bluetoothAdapter;
      });
    } catch (e) {
      showNoPrinterDialog2(e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
    }
    if (kDebugMode) {
      print(bluetoothAdapter);
    }
  }

  Widget _buildPrintButton() {
    return Align(
      alignment: Alignment.center,
      child: MaterialButton(
        minWidth: 120,
        color: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(2.0),
          ),
        ),
        onPressed: () {
          _submit();
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
          child: Text(
            'Print',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      Expanded(
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'string to print';
            }
            return null;
          },
          initialValue: _testString ?? '',
          onSaved: (value) => _testString = value!.trim(),
          style: GoogleFonts.dmSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            label: Text(
              ' string ',
              style: GoogleFonts.dmSans(
                textStyle: TextStyle(
                  color: Colors.black.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            filled: true,
            hintText: 'string to print',
            labelStyle: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.3), width: 0.6),
              // borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(5.0),
            ),
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.3), width: 0.6),
              // borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(5.0),
            ),
            focusColor: const Color.fromRGBO(243, 242, 242, 1),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.3), width: 0.5),
              borderRadius: BorderRadius.circular(5.0),
            ),
            hintStyle: GoogleFonts.dmSans(
              textStyle: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          maxLines: 1,
          textAlign: TextAlign.start,
        ),
      ),
      const SizedBox(
        width: 20,
      ),
      _buildPrintButton(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_devicesMsg != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _devicesMsg!,
                    style: GoogleFonts.dmSans(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              if (_macAddress != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _macAddress!,
                    style: GoogleFonts.dmSans(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }
}









/*
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _trytwoPlugin = Trytwo();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _trytwoPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
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
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
*/