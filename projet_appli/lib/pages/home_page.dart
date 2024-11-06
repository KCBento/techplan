import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/techplan.png"),
          const Text(
            "Techplan",
            style: TextStyle(fontSize: 40, fontFamily: "Poppins"),
          ),
          const Text(
            "Bienvenue sur l'agenda de technicien",
            style: TextStyle(
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          //Button :
          /*Padding(padding: EdgeInsets.only(top: 20)),
          ElevatedButton.icon(
            style: const ButtonStyle(
                padding: MaterialStatePropertyAll(EdgeInsets.all(20)),
                backgroundColor: MaterialStatePropertyAll(Colors.green)),
            onPressed: () {
              Navigator.push(context,
                  PageRouteBuilder(pageBuilder: (_, __, ___) => EventPage()));
            },
            label: const Text(
              "Afficher le planning",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            icon: const Icon(
              Icons.calendar_month,
              size: 30,
              color: Colors.white,
            ),
          ) */
        ],
      ),
    );
  }
}
