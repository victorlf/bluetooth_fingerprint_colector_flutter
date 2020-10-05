import 'package:flutter/material.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/constants.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/mode.dart';

SnackBar beaconRssiSnackbar(List node1RssiList, int node1RssiListLength) {
  int rssiMode = mode(node1RssiList, node1RssiListLength);

  Text content;
  if (node1RssiList.isNotEmpty) {
    //content = Text(
    //    '${device.getName()}, ${device.getAddress()}, ${device.getRssi()}');
    content = Text(
      'Node1: $rssiMode dBm',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  } else {
    content = Text(
      'No beacon was Found',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  return SnackBar(
    content: content,
    duration: kFiveSec,
    backgroundColor: Color(0xFF3C42BA),
  );
}
