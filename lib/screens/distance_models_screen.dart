import 'package:bluetooth_fingerprint_colector_flutter/components/reusable_card.dart';
import 'package:bluetooth_fingerprint_colector_flutter/screens/action_selection_screen.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/action_arguments.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/constants.dart';
import 'package:flutter/material.dart';

class DistanceModelsScreen extends StatelessWidget {
  static const String id = 'distance_model_screen';

  @override
  Widget build(BuildContext context) {
    ActionArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Model to Use'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
              colour: Colors.blue,
              cardChild: Center(
                child: Text(
                  'Modelo 1',
                  style: kLabelTextStyle,
                ),
              ),
              onPress: () {
                Navigator.pushNamed(
                  context,
                  ActionSelectionScreen.id,
                  arguments:
                      ActionArguments(technology: args.technology, model: 1),
                );
              },
            ),
          ),
          Expanded(
            child: ReusableCard(
              colour: Colors.blue,
              cardChild: Center(
                child: Text(
                  'Model 2',
                  style: kLabelTextStyle,
                ),
              ),
              onPress: () {
                Navigator.pushNamed(
                  context,
                  ActionSelectionScreen.id,
                  arguments:
                      ActionArguments(technology: args.technology, model: 2),
                );
              },
            ),
          ),
          Expanded(
            child: ReusableCard(
              colour: Colors.blue,
              cardChild: Center(
                child: Text(
                  'Model 3',
                  style: kLabelTextStyle,
                ),
              ),
              onPress: () {
                Navigator.pushNamed(
                  context,
                  ActionSelectionScreen.id,
                  arguments:
                      ActionArguments(technology: args.technology, model: 3),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
