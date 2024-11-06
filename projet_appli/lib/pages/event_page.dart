import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final events = [
    {
      "Speaker": "Canari Rouge",
      "Date": "06/02/2013",
      "Subject": "Anniversaire",
      "Avatar": "image1"
    },
    {
      "Speaker": "Canari Noir",
      "Date": "01/01/2014",
      "Subject": "Anniversaire",
      "Avatar": "image2"
    },
    {
      "Speaker": "Canari Jaune",
      "Date": "02/08/2015",
      "Subject": "Anniversaire",
      "Avatar": "image3"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final Speaker = event["Speaker"];
            final Date = event["Date"];
            final Subject = event["Subject"];
            final Avatar = event["Avatar"];

            return Card(
              child: ListTile(
                leading: Image.asset("assets/images/$Avatar.jpg"),
                title: Text("$Speaker ($Date)"),
                subtitle: Text("$Subject"),
                trailing: Icon(Icons.info),
              ),
            );
          }),
    );
  }
}
