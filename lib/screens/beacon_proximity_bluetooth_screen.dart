import 'dart:async';

import 'package:bluetooth_fingerprint_colector_flutter/utilities/action_arguments.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/node_functions.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/distance_models.dart';
import 'package:bluetooth_fingerprint_colector_flutter/components/device_info_card.dart';
import 'package:bluetooth_fingerprint_colector_flutter/components/info_card.dart';
import 'package:bluetooth_fingerprint_colector_flutter/components/reusable_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/constants.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:bluetooth_fingerprint_colector_flutter/components/bluetooth_off_screen.dart';
import 'package:bluetooth_fingerprint_colector_flutter/components/floating_action_button_blue_off.dart';
import 'package:device_info/device_info.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/mode.dart';
import 'package:location/location.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/notification_methods.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BeaconProximityBluetoothScreen extends StatefulWidget {
  static const String id = 'beacon_proximity_bluetooth_screen';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const BeaconProximityBluetoothScreen(
      {Key key, this.flutterLocalNotificationsPlugin})
      : super(key: key);
  @override
  _BeaconProximityBluetoothScreenState createState() =>
      _BeaconProximityBluetoothScreenState();
}

class _BeaconProximityBluetoothScreenState
    extends State<BeaconProximityBluetoothScreen> {
  final String _appBarTitle = 'Beacon Proximity Bluetooth';
  bool _locationModeOn = false;
  ActionArguments _args;
  //Node _nodeToBeAnalysed;
  List<int> rssiList = [];
  List<int> node1RssiList = [];
  List<ScanResult> resultsList = [];
  Device oldCloserDevice;
  int userLogCounter = 0;
  //Map<String, List<int>> resultsMap = {};
  int _rssiMode;
  double _distance;
  int _idCounter = 1;
  int _currentIdCounter;
  // ========================
  List<int> deviceRssiList = [];
  Map<DeviceScanResult, List<int>> deviceMap = {};
  // ========================
  final _textFieldController = TextEditingController();
  String distanceTextFieldValue = '';
  Color focusedTextFieldBorderColor = Colors.blue;
  bool _validate = false;
  Color textFieldBorderColor = Colors.black;
  double _realDistance = 1.0;
  String dropdownValue = 'node1';
  double distanceDropdownValue = 1.0;
  double heightDropdownValue = 190.0;
  double _height = 190.0;
  bool _pressFlotingActionButton = false;
  // Variable to get device info
  AndroidDeviceInfo _androidInfo;
  // Location
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  // Function to get Device Info
  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Future androidInfoFunc() async {
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    _androidInfo = info;
    print('Running on ${_androidInfo.androidId}');

    Location location = new Location();

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  FlutterBlue flutterBlue = FlutterBlue.instance;

  void initBluetooth() async {
    print('startScan o/ ');
    //setState(() {
    node1RssiList.clear();
    resultsList.clear();
    //});
    flutterBlue.startScan(timeout: kOneSec);
    await scanResultsHandler(flutterBlue.scanResults);
  }

  Future<void> scanResultsHandler(Stream<List<ScanResult>> stream) async {
    List<ScanResult> temp = [];
    await for (var value in stream) {
      for (ScanResult result in value) {
        if (kNodesMap.containsValue(result.device.id.toString())) {
          temp.add(result);
        }
      }
      resultsList = temp;
    }
  }

  Device compareScanResults(List<ScanResult> results) {
    List<int> tempList = [];
    Map<String, List<int>> resultsMap = {};
    kNodesMap.forEach((key, value) {
      for (ScanResult r in results) {
        if (r.device.name == key) {
          if (resultsMap.containsKey(key)) {
            tempList = [];
            tempList = resultsMap[key].toList();
            tempList.add(r.rssi);
            resultsMap[key] = tempList;
          } else {
            tempList = [];
            tempList.add(r.rssi);
            resultsMap[key] = tempList;
          }
        }
      }
    });

    // Its returning the mode but it can be changed to mean or medium easily
    Map<String, int> resultsModeMap = {};
    resultsMap.forEach((key, value) {
      print("$key : $value");
      resultsModeMap[key] = mode(value, value.length);
    });
    print("Before remove: $resultsModeMap");

    String maxRssiKey;
    resultsModeMap.forEach((key, value) {
      if (maxRssiKey != null) {
        maxRssiKey = value > resultsModeMap[maxRssiKey] ? key : maxRssiKey;
      } else {
        maxRssiKey = key;
      }
    });

    int maxRssiValue = resultsModeMap[maxRssiKey];
    print("After remove: $maxRssiKey, $maxRssiValue");
    //return [maxRssiKey, maxRssiValue];
    return Device(maxRssiKey, kNodesMap[maxRssiKey], maxRssiValue);
  }

  Future<void> writeLog(Device device) async {
    Firestore db = Firestore.instance;
    bool exists = false;

    try {
      await db
          .collection('userLog')
          .document('bluetooth')
          .collection('androidID_${_androidInfo.androidId}')
          .document('${device.getName()}')
          .get()
          .then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
    } catch (e) {
      return false;
    }

    if (exists) {
      db
          .collection('userLog')
          .document('bluetooth')
          .collection('androidID_${_androidInfo.androidId}')
          .document('${device.getName()}')
          .updateData({
        'range': device.getRssi(),
        'counter': FieldValue.increment(1),
      });
    } else {
      db
          .collection('userLog')
          .document('bluetooth')
          .collection('androidID_${_androidInfo.androidId}')
          .document('${device.getName()}')
          .setData({
        'range': device.getRssi(),
        'counter': 1,
      });
    }
  }

  Widget scanResultsCards(
      bool isScanning, ActionArguments args, List<ScanResult> results) {
    if (isScanning == false) {
      if (results.isNotEmpty) {
        Device closerDevice = compareScanResults(results);
        oldCloserDevice = compareScanResults(results);
        if (userLogCounter == 0) {
          writeLog(closerDevice);
          showNotificationWithDefaultSound(
              widget.flutterLocalNotificationsPlugin);
          userLogCounter = 1;
        }
        return ListView(
          children: <Widget>[
            DeviceInfoCard(
              name: closerDevice.getName(),
              address: closerDevice.getAddress(),
              rssi: closerDevice.getRssi(),
            ),
          ],
        );
      } else if (oldCloserDevice != null) {
        return ListView(
          children: <Widget>[
            DeviceInfoCard(
              name: oldCloserDevice.getName(),
              address: oldCloserDevice.getAddress(),
              rssi: oldCloserDevice.getRssi(),
            ),
          ],
        );
      } else {
        return Center(
          child: Container(
            padding: EdgeInsets.all(50.0),
            child: kProgressCircle,
          ),
        );
      }
    } else if (oldCloserDevice != null) {
      return ListView(
        children: <Widget>[
          DeviceInfoCard(
            name: oldCloserDevice.getName(),
            address: oldCloserDevice.getAddress(),
            rssi: oldCloserDevice.getRssi(),
          ),
        ],
      );
    } else {
      return Center(
        child: Container(
          padding: EdgeInsets.all(50.0),
          child: kProgressCircle,
        ),
      );
    }
  }

  void periodicScan() {
    Timer.periodic(kFiveSec, (Timer t) {
      // 3 measures are gonna be done
      // if (_idCounter > 2) {
      //   t.cancel();
      // }
      _locationModeOn = true;
      _pressFlotingActionButton = true;
      if (this.mounted) {
        setState(() {
          initBluetooth();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //initBluetooth();

    // Get device info
    androidInfoFunc();

    periodicScan();
  }

  @override
  Widget build(BuildContext context) {
    // Arguments needed to decide which distanceModel to use
    _args = ModalRoute.of(context).settings.arguments;

    return StreamBuilder<Object>(
        stream: flutterBlue.state,
        initialData: BluetoothState.unknown,
        builder: (mainContext, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on && _locationModeOn) {
            return Scaffold(
              appBar: AppBar(
                title: Text(_appBarTitle),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //beaconRssi(),
                  //scanResultsCards(),
                  Expanded(
                    child: StreamBuilder(
                      stream: flutterBlue.isScanning,
                      builder: (context, snapshot) {
                        final isScanning = snapshot.data;
                        return scanResultsCards(isScanning, _args, resultsList);
                      },
                    ),
                  ),
                ],
              ),
              // Button removed for periodic scan implementation
              // floatingActionButton: Builder(builder: (BuildContext context) {
              //   return FloatingActionButton(
              //     onPressed: () {
              //       _pressFlotingActionButton = true;
              //       setState(() {
              //         initBluetooth();
              //       });

              //       //periodicScan();
              //     },
              //     child: Icon(Icons.location_searching),
              //     backgroundColor: Color(0xFF3C42BA),
              //   );
              // }),
            );
          } else if (state == BluetoothState.on && !_locationModeOn) {
            return Scaffold(
              appBar: AppBar(
                title: Text(_appBarTitle),
              ),
              body: Center(
                child: Column(
                  //mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Iniciar Medida',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline
                            .copyWith(color: Colors.grey[500])),
                  ],
                ),
              ),
              // Button removed for periodic scan implementation
              // floatingActionButton: Builder(builder: (BuildContext context) {
              //   return FloatingActionButton(
              //     onPressed: () {
              //       _locationModeOn = true;
              //       _pressFlotingActionButton = true;
              //       // setState(() {
              //       //   initBluetooth();
              //       // });
              //       periodicScan();
              //     },
              //     child: Icon(Icons.location_searching),
              //     backgroundColor: Color(0xFF3C42BA),
              //   );
              // })
            );
          }
          _locationModeOn = false;
          return Scaffold(
            appBar: AppBar(
              title: Text(_appBarTitle),
            ),
            body: BluetoothOffScreen(state: state),
            floatingActionButton: FloatingActionButtonBlueOff(state: state),
          );
        });
  }
}
