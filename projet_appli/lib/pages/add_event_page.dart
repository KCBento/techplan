import 'package:flutter/material.dart';


import '../database.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formkey = GlobalKey<FormState>();
  final LoginController = TextEditingController();
  final PassWordController = TextEditingController();
  bool _isPasswordVisible = false;

  /*String selectedNameType = "GHLAMALLAH BOUZID";*/

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

      bool estValide = await DatabaseHelper().verifierIdentifiants(login, motDePasse);

      if (estValide) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connexion réussie")),
        );
        // Naviguer vers une autre page ou faire d'autres actions après connexion réussie
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Identifiant ou mot de passe incorrect")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 156, bottom: 10),
                  child: (const Text(
                    "Connexion",
                    style: TextStyle(fontSize: 35),
                  )),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Identifiant",
                      labelStyle: TextStyle(color: Colors.black),
                      hintText: "Veuillez saisir un identifiant",
                      border: OutlineInputBorder()
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
                            ? Icons.visibility // Si le mot de passe est visible, affiche l'icône "œil"
                            : Icons.visibility_off, // Sinon afficher l'icône "œil barré"
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
                        style: TextStyle(color: Colors.black),
                      ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 300, left: 10),
                  child: (
                    const Text("Avez-vous oublier un identifiant ou mot de passe ?"
                        "Veuillez nous contacter sur ce 05 87 98 45 61",
                      style: TextStyle(
                        fontSize: 15.6
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
