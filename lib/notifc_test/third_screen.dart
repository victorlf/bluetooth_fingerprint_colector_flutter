import 'dart:async' show Future;

import 'dart:io' show File;

import 'dart:typed_data' show Int64List;

import 'dart:ui' show Color, FontWeight, Radius, VoidCallback;

import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

//import 'schedule_notifications.dart';

class ThirdScreen extends StatefulWidget {
  static const String id = 'third';

  //ThirdScreen(this.payload, this.notifications);
  //ThirdScreen(this.notifications);

  //final String payload;
  //final ScheduleNotifications notifications;

  @override
  State<StatefulWidget> createState() => ThirdScreenState();
}

class ThirdScreenState extends State<ThirdScreen> {
  String _payload;

  @override
  void initState() {
    super.initState();
    //_payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
