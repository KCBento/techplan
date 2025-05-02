import 'package:flutter/material.dart';


import 'agenda_app.dart';
import 'database.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final _formkey = GlobalKey<FormState>();
  final LoginController = TextEditingController();
  final PassWordController = TextEditingController();
  bool _isPasswordVisible = false;



  @override
  void dispose() {
    super.dispose();
    LoginController.dispose();
    PassWordController.dispose();
  }

  Future<void> _connexion() async {
    if (_formkey.currentState!.validate()) {
      String login = LoginController.text;
      String motDePasse = PassWordController.text;

      bool estValide = await DatabaseHelper().checkConnection(login, motDePasse);

      if (estValide) {
        int idTechnician = await DatabaseHelper().getTechnicianIdByCredentials(login, motDePasse);
        DatabaseHelper().updateTechnicianLoginStatus(idTechnician);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connexion réussie")),
        );
        // Naviguer vers une autre page ou faire d'autres actions après connexion réussie
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Identifiant ou mot de passe incorrect")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bienvenue sur l'agenda de techplan"),titleTextStyle: TextStyle(color: Colors.black, fontSize: 25),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 100, bottom: 10),
                    child: const Text(
                      "Connexion",
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Identifiant",
                        labelStyle: TextStyle(color: Colors.black),
                        hintText: "Veuillez saisir un identifiant",
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez compléter ce champ";
                        }
                        return null;
                      },
                      controller: LoginController,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: TextFormField(
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Mot De Passe",
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: "Veuillez saisir un mot de passe",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility // Si le mot de passe est visible
                                : Icons.visibility_off, // Si le mot de passe est masqué
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez compléter ce champ";
                        }
                        return null;
                      },
                      controller: PassWordController,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _connexion,
                      child: const Text(
                        "Valider",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 130, left: 10, bottom: 10),
                    child: const Text(
                      "Avez-vous oublié un identifiant ou mot de passe ?",
                      style: TextStyle(
                        fontSize: 15.6,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: const Text(
                      "Veuillez nous contacter au 05 87 98 45 61",
                      style: TextStyle(
                        fontSize: 15.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

}