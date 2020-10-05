import 'package:bluetooth_fingerprint_colector_flutter/utilities/node_functions.dart';
import 'package:flutter/material.dart';

const Duration kFiveSec = Duration(seconds: 5);
const Duration kTenSec = Duration(seconds: 10);

const Duration kThreeSec = Duration(seconds: 3);
const Duration kOneSec = Duration(seconds: 1);
const Duration kTwoSec = Duration(seconds: 2);
const Duration kFourSec = Duration(seconds: 4);

const kProgressCircle = CircularProgressIndicator(
  backgroundColor: Color(0xFFFFE0E0E0),
  strokeWidth: 10.0,
);

const kLabelTextStyle = TextStyle(
  fontSize: 35.0,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);

const kInfoTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);

Map<String, Node> kNodesMap = {
  'node1': kNode1,
  'node2': kNode2,
};

Node kNode1 = Node('node1', '30:AE:A4:EC:9C:F6');
Node kNode2 = Node('node2', 'FA:KE:AS:FU:CK:00');