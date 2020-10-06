import 'package:bluetooth_fingerprint_colector_flutter/screens/test_model_bluetooth_screen.dart';
import 'package:bluetooth_fingerprint_colector_flutter/screens/beacon_proximity_bluetooth_screen.dart';
import 'package:bluetooth_fingerprint_colector_flutter/components/reusable_card.dart';
import 'package:bluetooth_fingerprint_colector_flutter/screens/fingerprint_screen.dart';
import 'package:bluetooth_fingerprint_colector_flutter/screens/test_model_screen.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/action_arguments.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/constants.dart';
import 'package:flutter/material.dart';

class ActionSelectionScreen extends StatelessWidget {
  static const String id = 'action_selection_screen';

  @override
  Widget build(BuildContext context) {
    ActionArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('What you want to do?'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
              colour: Colors.blue,
              cardChild: Center(
                child: Text(
                  'Test Model',
                  style: kLabelTextStyle,
                ),
              ),
              onPress: () {
                Navigator.pushNamed(
                  context,
                  args.technology == 'Bluetooth'
                      ? TestModelBluetoothScreen.id
                      : TestModelScreen.id,
                  arguments: ActionArguments(
                      technology: args.technology, model: args.model),
                );
              },
            ),
          ),
          Expanded(
            child: ReusableCard(
              colour: Colors.blue,
              cardChild: Center(
                child: Text(
                  'Beacon Proximity',
                  style: kLabelTextStyle,
                ),
              ),
              onPress: () {
                Navigator.pushNamed(
                  context,
                  args.technology == 'Bluetooth'
                      ? BeaconProximityBluetoothScreen.id
                      : TestModelScreen.id,
                  arguments: ActionArguments(
                      technology: args.technology, model: args.model),
                );
              },
            ),
          ),
          Expanded(
            child: ReusableCard(
              colour: Colors.blue,
              cardChild: Center(
                child: Text(
                  'Fingerprint',
                  style: kLabelTextStyle,
                ),
              ),
              onPress: () {
                Navigator.pushNamed(
                  context,
                  args.technology == 'Bluetooth'
                      ? TestModelBluetoothScreen.id
                      : TestModelScreen.id,
                  arguments: ActionArguments(
                      technology: args.technology, model: args.model),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
