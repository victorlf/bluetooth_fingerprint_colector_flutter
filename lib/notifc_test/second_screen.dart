import 'dart:async' show Future;

import 'dart:io' show File;

import 'dart:typed_data' show Int64List;

import 'dart:ui' show Color, FontWeight, Radius, VoidCallback;

import 'package:bluetooth_fingerprint_colector_flutter/notifc_test/third_screen.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

//import 'schedule_notifications.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/schedule_notifications.dart';
import 'main_schedule_notif_test.dart';
import 'package:bluetooth_fingerprint_colector_flutter/utilities/action_arguments.dart';

class SecondScreen extends StatefulWidget {
  static const String id = 'second';

  //SecondScreen(this.payload, this.notifications);
  //SecondScreen(this.notifications);

  //final String payload;
  //final ScheduleNotifications notifications;

  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  ScheduleNotifications _notifications;

  @override
  void initState() {
    super.initState();
    //_payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    ActionArguments args = ModalRoute.of(context).settings.arguments;
    _notifications = args.notifications;

    // _notifications.init(onSelectNotification: (String payload) async {
    //   if (payload == null || payload.trim().isEmpty) return null;
    //   Navigator.pop(context);
    // });

    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen with payload:'), //${(_payload ?? '')}'),
      ),
      body: Center(
        child: Column(
          children: [
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
            _PaddedRaisedButton(
              buttonText: 'Show plain notification with payload',
              onPressed: () => _notifications.show(
                id: 0,
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker',
                title: 'plain title',
                body: 'plain body',
                payload: ThirdScreen.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaddedRaisedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const _PaddedRaisedButton({
    @required this.buttonText,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: RaisedButton(child: Text(buttonText), onPressed: onPressed),
    );
  }
}
