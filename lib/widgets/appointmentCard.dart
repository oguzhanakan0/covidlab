import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  AppointmentCard(this.appointment);
  final dynamic appointment;

  @override
  Widget build(BuildContext context) {
    if (DateTime.parse(appointment["test_date"]).isAfter(DateTime.now())) {
      return Container(
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 0,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(50),
              onTap: () {
                print('Card tapped.');
              },
              // shadowColor:Colors.grey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.access_time_rounded,
                      color: Colors.amber,
                    ),
                    title: Text(appointment["location"]),
                    subtitle: Text(
                      appointment["test_date"],
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
            ),
          ));
    } else {
      return Text("dasd");
    }
  }
}
