import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formkey = GlobalKey<FormState>();

  final LoginController = TextEditingController();
  final PassWordController = TextEditingController();

  /*String selectedNameType = "GHLAMALLAH BOUZID";*/

  @override
  void dispose() {
    super.dispose();

    LoginController.dispose();
    PassWordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Form(
          key: _formkey,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 156, bottom: 10),
                child: (const Text(
                  "Connexion",
                  style: TextStyle(fontSize: 20),
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
                      border: OutlineInputBorder()),
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
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                      labelText: "Mot De Passe",
                      labelStyle: TextStyle(color: Colors.black),
                      hintText: "Veuillez saisir un mot de passe",
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez compléter ce champ";
                    }
                    return null;
                  },
                  controller: PassWordController,
                ),
              ),
              /* Container(
                margin: EdgeInsets.only(bottom: 20),
                child: DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(
                          value: "GHLAMALLAH BOUZID",
                          child: Text("GHLAMALLAH BOUZID")),
                      DropdownMenuItem(child: Text("BOUZID GHLAMALLAH"))
                    ],
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    value: selectedNameType,
                    onChanged: (value) {
                      setState(() {
                        selectedNameType = value!;
                      });
                    }),
              ), */
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          final Login = LoginController.text;
                          final PassWord = PassWordController.text;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                              "Veuillez patienter...",
                            )),
                          );
                          FocusScope.of(context).requestFocus(FocusNode());

                          /*print("Ajout de nom $Name par le prénom $FirstName");*/
                          // print("Type de nom $selectedNameType");
                        }
                      },
                      child: const Text(
                        "Valider",
                        style: TextStyle(color: Colors.black),
                      )))
            ],
          )),
    );
  }
}
