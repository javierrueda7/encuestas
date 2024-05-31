import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/widgets/forms_widgets.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          elevation: 0,
          title: const Text(
            "RECUPERAR CONTRASEÑA",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 244, 246, 252),
          Color.fromARGB(255, 222, 224, 227),
          Color.fromARGB(255, 222, 224, 227)
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: buildEmailField('EMAIL', _emailTextController, false),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: firebaseButton(context, "RECUPERAR CONTRASEÑA", () {
                  FirebaseAuth.instance
                      .sendPasswordResetEmail(
                          email: _emailTextController.text)
                      .then((value) => Navigator.of(context).pop());
                }),
              )
            ]),
          ),
        ),
      )
    );
  }
}
