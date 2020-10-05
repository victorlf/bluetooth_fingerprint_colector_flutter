import 'package:flutter/material.dart';

class DeviceInfoCard extends StatelessWidget {
  const DeviceInfoCard({
    this.name,
    this.address,
    @required this.rssi,
  });

  final String name;
  final String address;
  final int rssi;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
        child: Text(
          '$name : $address : $rssi dBm',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
