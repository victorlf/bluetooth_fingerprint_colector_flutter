import 'package:bluetooth_fingerprint_colector_flutter/utilities/action_arguments.dart';
import 'package:flutter/material.dart';

class FingerprintScreen extends StatefulWidget {
  @override
  _FingerprintScreenState createState() => _FingerprintScreenState();
  static const id = 'fingerprint_screen';
}

class _FingerprintScreenState extends State<FingerprintScreen> {
  @override
  Widget build(BuildContext context) {
    ActionArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Fingerprint'),
      ),
      body: Column(
        children: <Widget>[
          Text('Tecnologia: ${args.technology}'),
          Text('Modelo: ${args.model}'),
        ],
      ),
    );
  }
}
