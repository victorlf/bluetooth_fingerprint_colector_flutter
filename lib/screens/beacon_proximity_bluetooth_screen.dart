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

class BeaconProximityBluetoothScreen extends StatefulWidget {
  static const String id = 'beacon_proximity_bluetooth_screen';
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
  Map<String, List<int>> resultsMap = {};
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
    print('Running on ${_androidInfo.model}'); // e.g. "Moto G (4)"

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
    setState(() {
      node1RssiList.clear();
      resultsList.clear();
    });
    flutterBlue.startScan(timeout: kOneSec);
    await scanResultsHandler(flutterBlue.scanResults);
  }

  void ff(List<ScanResult> results) {
    // for (ScanResult r in results) {
    //   print('${r.device.name} : ${r.device.id.toString()} : ${r.rssi}');
    // }
    List<int> tempList = [];
    kNodesMap.forEach((key, value) {
      for (ScanResult r in results) {
        if (resultsMap[key] != null) {
          if (r.device.name == key) {
            tempList = resultsMap[key];
            tempList.add(r.rssi);
            resultsMap[key] = tempList;
          }
        } else {
          tempList = [];
          tempList.add(r.rssi);
          resultsMap[key] = tempList;
        }
      }
    });

    resultsMap.forEach((key, value) {
      print("$key : $value");
    });
    // kNodesMap.forEach((key, value) {
    //   print("$key : $value");
    // });
  }

  Future<List<ScanResult>> scanResultsHandler(
      Stream<List<ScanResult>> stream) async {
    stream.listen((event) {
      for (ScanResult result in event) {
        if (kNodesMap.containsValue(result.device.id.toString())) {
          resultsList.add(result);
          // print(
          //     "${result.device.name} : ${result.device.id.toString()} : ${result.rssi}");
        }
      }
    });
  }

  Widget scanResultsCards(
      bool isScanning, ActionArguments args, List<ScanResult> results) {
    if (isScanning == false) {
      ff(results);
      if (rssiList.isNotEmpty) {
        // mode
        _rssiMode = mode(rssiList, rssiList.length);
        //_nodeToBeAnalysed = kNodesMap[dropdownValue];

        _args.model == 1
            ? _distance = calculateDistanceModel1(_rssiMode)
            : _distance = 100.100;

        double diff = calculateDifference(_realDistance, _distance);

        // It will record only when the textField has a entry
        //if (_validate == false) {

        // if (_pressFlotingActionButton == true) {
        //   _realDistance = distanceDropdownValue;
        //   _height = heightDropdownValue;
        //   Firestore.instance
        //       .collection('distanceMeasures_${_androidInfo.model}')
        //       .document('bluetooth')
        //       .collection('realDistance${_realDistance}_$_height')
        //       .document('$_idCounter')
        //       .setData({
        //     'nodeName': _nodeToBeAnalysed.getName(),
        //     //'rssi': _rssiMode,
        //     'rssi': rssiList,
        //     //'calcDistance': _distance,
        //     'realDistance': _realDistance,
        //     'accuracy': diff,
        //     'height': _height,
        //   });
        //   _currentIdCounter = _idCounter;
        //   ++_idCounter;
        //   _pressFlotingActionButton = false;
        // }

        print('All RSSIs: $rssiList');
        print('length: ${rssiList.length}');
        print('rssiMode: $_rssiMode');
        print('first: ${rssiList.first}');
        print('first: ${rssiList.last}');
        print('idCounter: $_currentIdCounter');

        //rssiList.clear();

        return ListView(
          children: <Widget>[
            DeviceInfoCard(
              //name: _nodeToBeAnalysed.getName(),
              name: dropdownValue,
              //address: _nodeToBeAnalysed.getAddress(),
              address: kNodesMap[dropdownValue],
              rssi: _rssiMode,
            ),
            InfoCard(info: 'Distância Calc: $_distance m'),
            InfoCard(info: 'Distância real: $_realDistance m'),
            InfoCard(info: 'Acurácia: $diff m'),
            InfoCard(
              info: 'Altura: $_height cm',
            ),
            InfoCard(info: 'id: $_currentIdCounter')
          ],
        );
      } else {
        return ReusableCard(
          colour: Colors.blue,
          cardChild: Center(
            child: Text(
              'rssiList is Empty',
              style: kInfoTextStyle,
            ),
          ),
        );
      }
    } else {
      return Center(
        child: Container(
          padding: EdgeInsets.all(50.0),
          // height: MediaQuery.of(context).size.width,
          // width: MediaQuery.of(context).size.width,
          child: kProgressCircle,
        ),
      );
    }
  }

  void periodicScan() {
    Timer.periodic(kTwoSec, (Timer t) {
      // 3 measures are gonna be done
      if (_idCounter > 2) {
        t.cancel();
      }
      _pressFlotingActionButton = true;
      initBluetooth();
    });
  }

  @override
  void initState() {
    super.initState();
    //initBluetooth();

    // Get device info
    androidInfoFunc();
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
                  // TextField(
                  //   controller: _textFieldController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderSide:
                  //           BorderSide(color: textFieldBorderColor, width: 0.6),
                  //     ),
                  //     labelText: 'Distância em metros',
                  //     focusedBorder: OutlineInputBorder(
                  //       borderSide: BorderSide(
                  //           color: focusedTextFieldBorderColor, width: 2.0),
                  //     ),
                  //     errorText: _validate ? 'Value Can\'t Be Empty' : null,
                  //   ),
                  //   onChanged: (value) {
                  //     distanceTextFieldValue = value;
                  //     _realDistance = double.parse(value);
                  //   },
                  // ),
                  DropdownButton<double>(
                    value: distanceDropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (double value) {
                      setState(() {
                        distanceDropdownValue = value;
                      });
                      //_realDistance = value;
                    },
                    items: <double>[1.0, 3.0, 5.0]
                        .map<DropdownMenuItem<double>>((double value) {
                      return DropdownMenuItem<double>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                  ),
                  DropdownButton<double>(
                    value: heightDropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (double value) {
                      setState(() {
                        heightDropdownValue = value;
                      });
                      //_height = value;
                    },
                    items: <double>[190.0, 200.0, 210.0, 220.0, 230.0, 240]
                        .map<DropdownMenuItem<double>>((double value) {
                      return DropdownMenuItem<double>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                  ),
                ],
              ),
              floatingActionButton: Builder(builder: (BuildContext context) {
                return FloatingActionButton(
                  onPressed: () {
                    // === TextField Logic ===
                    // if (_textFieldController.text.isEmpty) {
                    //   setState(() {
                    //     _validate = true;
                    //   });
                    // } else {
                    //   setState(() {
                    //     _validate = false;
                    //   });
                    //   initBluetooth();

                    //   _textFieldController.clear();
                    // }
                    _pressFlotingActionButton = true;
                    initBluetooth();
                    //periodicScan();
                  },
                  child: Icon(Icons.location_searching),
                  backgroundColor: Color(0xFF3C42BA),
                );
              }),
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
                      // Icon(
                      //   Icons.location_on,
                      //   size: 200.0,
                      //   color: Colors.grey[500],
                      // ),
                      //Text('Bluetooth Adapter is ${state.toString().substring(15)}.',
                      Text('Iniciar Medida',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline
                              .copyWith(color: Colors.grey[500])),
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String value) {
                          setState(() {
                            dropdownValue = value;
                          });
                        },
                        items: <String>['node1', 'node2']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      // TextField(
                      //   controller: _textFieldController,
                      //   keyboardType: TextInputType.number,
                      //   decoration: InputDecoration(
                      //     border: OutlineInputBorder(),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //           color: textFieldBorderColor, width: 0.6),
                      //     ),
                      //     labelText: 'Distância em metros',
                      //     focusedBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //           color: focusedTextFieldBorderColor, width: 2.0),
                      //     ),
                      //     errorText: _validate ? 'Value Can\'t Be Empty' : null,
                      //   ),
                      //   onChanged: (value) {
                      //     distanceTextFieldValue = value;
                      //     _realDistance = double.parse(value);
                      //   },
                      // ),
                      DropdownButton<double>(
                        value: distanceDropdownValue,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (double value) {
                          setState(() {
                            distanceDropdownValue = value;
                          });
                          //_realDistance = value;
                        },
                        items: <double>[1.0, 3.0, 5.0]
                            .map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem<double>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                      ),
                      DropdownButton<double>(
                        value: heightDropdownValue,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (double value) {
                          setState(() {
                            heightDropdownValue = value;
                          });
                          //_height = value;
                        },
                        items: <double>[190.0, 200.0, 210.0, 220.0, 230.0, 240]
                            .map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem<double>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: Builder(builder: (BuildContext context) {
                  return FloatingActionButton(
                    onPressed: () {
                      // === TextField Logic ===
                      // if (_textFieldController.text.isEmpty) {
                      //   setState(() {
                      //     _validate = true;
                      //   });
                      // } else {
                      //   _locationModeOn = true;

                      //   setState(() {
                      //     _validate = false;
                      //   });
                      //   initBluetooth();

                      //   _textFieldController.clear();
                      // }
                      // Future.delayed(kFiveSec).then((_) {
                      //   Scaffold.of(context).showSnackBar(beaconRssiSnackbar());
                      // });
                      _locationModeOn = true;
                      _pressFlotingActionButton = true;
                      initBluetooth();
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

  void dispose() {
    super.dispose();
    _textFieldController.dispose();
  }
}
