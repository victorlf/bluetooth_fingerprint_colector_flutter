import 'package:bluetooth_fingerprint_colector_flutter/components/reusable_card.dart';
import 'package:bluetooth_fingerprint_colector_flutter/screens/distance_models_screen.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/action_arguments.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/constants.dart';
import 'package:flutter/material.dart';

class TechnologySelectionScreen extends StatelessWidget {
  static const String id = 'technology_selection_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Technologies'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
              colour: Colors.blue,
              cardChild: Center(
                child: Text(
                  'Bluetooth 4.0',
                  style: kLabelTextStyle,
                ),
              ),
              onPress: () {
                Navigator.pushNamed(
                  context,
                  DistanceModelsScreen.id,
                  arguments: ActionArguments(technology: 'Bluetooth'),
                );
              },
            ),
          ),
          Expanded(
            child: ReusableCard(
              colour: Colors.blue,
              cardChild: Center(
                child: Text(
                  'WiFi',
                  style: kLabelTextStyle,
                ),
              ),
              onPress: () {
                Navigator.pushNamed(context, DistanceModelsScreen.id,
                    arguments: ActionArguments(technology: 'WiFi'));
              },
            ),
          )
        ],
      ),
    );
  }
}
