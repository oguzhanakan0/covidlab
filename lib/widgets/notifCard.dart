import 'dart:io';
import 'dart:typed_data';

import 'package:covidlab/variables/urls.dart';
import 'package:covidlab/widgets/manage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotifCard extends StatelessWidget {
  NotifCard({Key? key, required this.notif}) : super(key: key);
  final dynamic notif;

  @override
  Widget build(BuildContext context) {
    Color c;
    Icon i;

    switch (notif['notif_type']) {
      //   primary = 'P'
      //   warning = 'W'
      //   danger = 'D'
      //   success = 'S'
      case "P":
        c = Colors.blue.shade100;
        i = Icon(CupertinoIcons.info_circle_fill);
        break;
      case "W":
        c = Colors.amber.shade100;
        i = Icon(CupertinoIcons.question_circle_fill);
        break;
      case "D":
        c = Colors.red.shade100;
        i = Icon(CupertinoIcons.exclamationmark_circle_fill);
        break;
      case "S":
        c = Colors.green.shade100;
        i = Icon(CupertinoIcons.check_mark_circled_solid);
        break;
      default:
        c = Colors.red.shade600;
        i = Icon(CupertinoIcons.exclamationmark_circle_fill);
    }
    if (notif['date_read'] != null) {
      c = Colors.grey.shade300;
    }

    return Card(
      elevation: 0,
      color: c,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 12.0),
        leading: CircleAvatar(backgroundColor: Colors.white, child: i),
        title: Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                notif["title"],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                notif["content"],
                style: Theme.of(context).textTheme.caption,
              ),
            ])),
      ),
    );
  }
}
