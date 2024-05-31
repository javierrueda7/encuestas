import 'package:emailjs/emailjs.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/services/firebase_services.dart';
import 'package:forms_app/widgets/forms_widgets.dart';

class SendEmailPage extends StatefulWidget {
  const SendEmailPage({super.key});

  @override
  State<SendEmailPage> createState() => _SendEmailPageState();
}

class _SendEmailPageState extends State<SendEmailPage> {

  List users = [];

  void obtainUsersList() async {
    users = await getUsuarios();
  }
  
  final TextEditingController _emailTextController = TextEditingController();

   @override
  void initState() {
    super.initState();
    obtainUsersList();
  }  

  @override
  Widget build(BuildContext context) {
    obtainUsersList();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          elevation: 0,
          title: const Text(
            "ENVIAR INVITACIÓN",
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
                child: firebaseButton(context, "ENVIAR", () {
                  final userWithEmail = users.firstWhere(
                    (user) => user['email'] == _emailTextController.text,
                    orElse: () => null,
                  );
                  if (userWithEmail != null) {
                    sendEmail(_emailTextController.text)
                      .then((value) => Navigator.of(context).pop());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('La dirección.', style: TextStyle(color: Colors.white),),
                        duration: Duration(seconds: 4),
                        backgroundColor: Color.fromRGBO(214, 66, 66, 1),
                      ),
                    );
                  }                
                })
              )
            ]),
          ),
        ),
      )
    );
  }
}

Future<bool> sendEmail(String email) async {
  try {
    await EmailJS.send(
      'service_e5c19tj',
      'template_ztn4t8n',
      {
        'to_email': email,
      },
      const Options(
        publicKey: 'i6iYK5YfmoXHpMpIB',
        privateKey: 'hoGKB12SFD8-8sDOC0eJl'
      ),
    );
    print('SUCCESS!');
    return true;
  } catch (error) {
    if (error is EmailJSResponseStatus) {
      print('ERROR... ${error.status}: ${error.text}');
    }
    print(error.toString());
    return false;
  }
}

