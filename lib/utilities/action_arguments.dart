import 'schedule_notifications.dart';

class ActionArguments {
  ActionArguments({this.technology, this.model, this.notifications});

  final String technology;
  final int model;
  final ScheduleNotifications notifications;
}
