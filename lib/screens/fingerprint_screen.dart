import 'dart:async';

import 'package:bluetooth_fingerprint_colector_flutter/screens/technology_selection_screen.dart';
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

class FingerprintScreen extends StatefulWidget {
  @override
  _FingerprintScreenState createState() => _FingerprintScreenState();
  static const id = 'fingerprint_screen';
}

class _FingerprintScreenState extends State<FingerprintScreen> {
  final String _appBarTitle = 'Fingerprint Bluetooth';
  bool _locationModeOn = false;
  List<int> rssiList = [];
  List<int> node1RssiList = [];
  List<ScanResult> resultsList = [];
  Device oldCloserDevice;
  int userLogCounter = 0;
  // ========================
  List<int> deviceRssiList = [];
  Map<DeviceScanResult, List<int>> deviceMap = {};
  // ========================
  String distanceTextFieldValue = '';
  Color focusedTextFieldBorderColor = Colors.blue;
  Color textFieldBorderColor = Colors.black;
  // Variable to get device info
  AndroidDeviceInfo _androidInfo;
  // Location
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  bool _pressFlotingActionButton = false;
  int _idCounter = 1;
  int _currentIdCounter;
  int xDropdownValue = 1;
  int yDropdownValue = 1;

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

  List<Device> compareScanResults(List<ScanResult> results) {
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
      //resultsModeMap[key] = mode(value, value.length);
      resultsModeMap[key] =
          ((value.reduce((a, b) => a + b)) / value.length).round();
    });
    print("Before remove: $resultsModeMap");

    List<Device> nodesFound = [];
    resultsModeMap.forEach((key, value) {
      nodesFound.add(Device(key, kNodesMap[key], value));
    });

    return nodesFound;

    // String maxRssiKey;
    // resultsModeMap.forEach((key, value) {
    //   if (maxRssiKey != null) {
    //     maxRssiKey = value > resultsModeMap[maxRssiKey] ? key : maxRssiKey;
    //   } else {
    //     maxRssiKey = key;
    //   }
    // });

    // int maxRssiValue = resultsModeMap[maxRssiKey];
    // print("After remove: $maxRssiKey, $maxRssiValue");
    // //return [maxRssiKey, maxRssiValue];
    // return Device(maxRssiKey, kNodesMap[maxRssiKey], maxRssiValue);
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

  Widget scanResultsCards(bool isScanning, List<ScanResult> results) {
    if (isScanning == false) {
      if (results.isNotEmpty) {
        List<Device> closestDevices = compareScanResults(results);
        // if (userLogCounter == 0) {
        //   writeLog(closerDevice);
        //   userLogCounter = 1;
        // }
        if (closestDevices.length == 5) {
          if (_pressFlotingActionButton) {
            Firestore.instance
                .collection('distanceMeasures_${_androidInfo.model}')
                .document('bluetooth')
                .collection('fingerprint')
                .document('$_idCounter')
                .setData({
              'x': xDropdownValue,
              'y': yDropdownValue,
              '${closestDevices[0].getName()}': closestDevices[0].getRssi(),
              '${closestDevices[1].getName()}': closestDevices[1].getRssi(),
              '${closestDevices[2].getName()}': closestDevices[2].getRssi(),
              '${closestDevices[3].getName()}': closestDevices[3].getRssi(),
              '${closestDevices[4].getName()}': closestDevices[4].getRssi(),
            });

            _currentIdCounter = _idCounter;
            ++_idCounter;
            _pressFlotingActionButton = false;
          }

          return ListView(
            children: <Widget>[
              for (Device device in closestDevices)
                DeviceInfoCard(
                  name: device.getName(),
                  address: device.getAddress(),
                  rssi: device.getRssi(),
                ),
              InfoCard(info: 'id: $_currentIdCounter')
            ],
          );
        } else if (closestDevices.length > 5) {
          return ListView(children: <Widget>[
            DeviceInfoCard(
              name: 'Too many beacons',
            ),
          ]);
        } else {
          return ListView(children: <Widget>[
            DeviceInfoCard(
              name: 'Only a few beacons',
            ),
          ]);
        }
      } else {
        return Center(
          child: Container(
            padding: EdgeInsets.all(50.0),
            child: kProgressCircle,
          ),
        );
      }
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
      _locationModeOn = true;
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

    //periodicScan();
  }

  @override
  Widget build(BuildContext context) {
    ActionArguments args = ModalRoute.of(context).settings.arguments;

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
                          return scanResultsCards(isScanning, resultsList);
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('X: '),
                        DropdownButton<int>(
                          value: xDropdownValue,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (int value) {
                            setState(() {
                              xDropdownValue = value;
                            });
                            //_height = value;
                          },
                          items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Y: '),
                        DropdownButton<int>(
                          value: yDropdownValue,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (int value) {
                            setState(() {
                              yDropdownValue = value;
                            });
                            //_height = value;
                          },
                          items: <int>[1, 2, 3]
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
                floatingActionButton: Builder(builder: (BuildContext context) {
                  return FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _locationModeOn = true;
                        _pressFlotingActionButton = true;
                        initBluetooth();
                      });
                      //periodicScan();
                    },
                    child: Icon(Icons.location_searching),
                    backgroundColor: Color(0xFF3C42BA),
                  );
                }));
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('X: '),
                          DropdownButton<int>(
                            value: xDropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (int value) {
                              setState(() {
                                xDropdownValue = value;
                              });
                              //_height = value;
                            },
                            items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                                .map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value'),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Y: '),
                          DropdownButton<int>(
                            value: yDropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (int value) {
                              setState(() {
                                yDropdownValue = value;
                              });
                              //_height = value;
                            },
                            items: <int>[1, 2, 3]
                                .map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value'),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                floatingActionButton: Builder(builder: (BuildContext context) {
                  return FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _locationModeOn = true;
                        _pressFlotingActionButton = true;
                        initBluetooth();
                      });
                      //periodicScan();
                    },
                    child: Icon(Icons.location_searching),
                    backgroundColor: Color(0xFF3C42BA),
                  );
                }));
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
