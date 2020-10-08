import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future showNotificationWithDefaultSound(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  // flutterLocalNotificationsPlugin.initialize(
  //     flutterLocalNotificationsPlugin.initializationSettings,
  //     onSelectNotification: onSelectNotification);

  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.max, priority: Priority.high);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics =
      new NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'New Post',
    'How to Show Notification in Flutter',
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );
}

// Future onSelectNotification(String payload) async {
//   showDialog(
//     context: context,
//     builder: (_) {
//       return new AlertDialog(
//         title: Text("PayLoad"),
//         content: Text("Payload : $payload"),
//       );
//     },
//   );
// }
