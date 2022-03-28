import 'package:covidlab/widgets/manage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatefulWidget {
  AppointmentCard({Key? key, required this.appointment}) : super(key: key);
  final dynamic appointment;

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  dynamic appointment;

  @override
  void initState() {
    appointment = widget.appointment;
    super.initState();
  }

  final f = DateFormat('EEE, MMM d, yyyy');
  final m = DateFormat('MMM');
  final d = DateFormat('d');
  final h = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    print(appointment);
    if (DateTime.parse(appointment["test_date"]).isAfter(DateTime.now())) {
      return Card(
        elevation: 0,
        color: Colors.blue.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(50),
          onTap: () async {
            {
              await showModalBottomSheet<bool>(
                useRootNavigator: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40))),
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                      heightFactor: 0.88,
                      child: ManageAppointment(appointment: appointment));
                },
              ).then((value) => setState(() {}));
            }
          },
          child: ListTile(
            contentPadding: EdgeInsets.all(36.0),
            leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(CupertinoIcons.lab_flask_solid)),
            title: Container(
                height: 96,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upcoming Appointment",
                        style: Theme.of(context).primaryTextTheme.caption,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "on ",
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            Text(
                              f.format(DateTime.parse(appointment["test_date"])
                                  .toLocal()),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                            )
                          ]),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "at ",
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            Text(
                              h.format(DateTime.parse(appointment["test_date"])
                                  .toLocal()),
                              style:
                                  Theme.of(context).primaryTextTheme.headline5,
                            )
                          ]),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "at ",
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            Text(
                              appointment["location"]["name"],
                              style:
                                  Theme.of(context).primaryTextTheme.subtitle1,
                            )
                          ])
                    ])),
          ),
        ),
      );
    } else {
      return Text("dasd");
    }
  }
}
