import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class FloatingActionButtonBlueOff extends StatelessWidget {
  const FloatingActionButtonBlueOff({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.error),
      backgroundColor: Colors.red,
    );
  }
}
