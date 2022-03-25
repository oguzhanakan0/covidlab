import 'package:covidlab/widgets/add.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {},
        ),
        trailing: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            {
              showModalBottomSheet<void>(
                useRootNavigator: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40))),
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                      heightFactor: 0.88, child: AddAppointment());
                },
              );
            }
          },
        ),
        middle: Text('CovidLab'),
      ),

      body: SafeArea(
        child: ListView(
        children: [
        Form(
            child: Container(
                padding: EdgeInsets.all(24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                        child: Card(
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
                                  leading: Icon(Icons.access_time_rounded),
                                  title: Text('Upcoming Appointment'),
                                  subtitle: Text(
                                    '12/23/2023 10:30 AM',
                                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ),
                      const Divider(
                        height: 50,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        color: CupertinoColors.systemGrey2,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              print('Card tapped.');
                            },
                            // mainAxisSize: MainAxisSize.min,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.access_time_filled_rounded),
                                  title: Text('Past Test'),
                                  subtitle: Text(
                                    '10/02/2022 09:30 AM',
                                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.end,
                                //   children: <Widget>[
                                //     IconButton(
                                //         icon: const Icon(
                                //           CupertinoIcons.arrow_right_circle,
                                //           color: Colors.black,
                                //           size: 30,
                                //         ),
                                //         padding: const EdgeInsets.all(0),
                                //         onPressed: () {}
                                //     ),
                                //     const SizedBox(width: 8),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                    ])))
        ]),

      )
        // Text('homepage'),
        // onPressed: () {},
    );
  }
}
