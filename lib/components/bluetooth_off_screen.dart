import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.bluetooth_disabled,
            size: 200.0,
            color: Colors.grey[500],
          ),
          //Text('Bluetooth Adapter is ${state.toString().substring(15)}.',
          Text('Bluetooth está desligado',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headline
                  .copyWith(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
