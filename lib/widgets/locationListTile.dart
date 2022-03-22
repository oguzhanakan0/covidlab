import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationListTile extends StatelessWidget {
  LocationListTile(this.location);
  final dynamic location;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(location["name"]),
        Text(
          location["address"],
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        location.containsKey("distance")
            ? Text(
                location["distance"].toStringAsFixed(1) + " miles",
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : SizedBox.shrink()
      ],
    );
  }
}
