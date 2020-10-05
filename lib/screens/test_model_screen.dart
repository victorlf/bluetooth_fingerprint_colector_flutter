import 'package:bluetooth_fingerprint_colector_flutter/utilities/action_arguments.dart';
import 'package:flutter/material.dart';

class TestModelScreen extends StatefulWidget {
  @override
  _TestModelScreenState createState() => _TestModelScreenState();
  static const id = 'test_model_screen';
}

class _TestModelScreenState extends State<TestModelScreen> {
  @override
  Widget build(BuildContext context) {
    final ActionArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Test Model'),
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
