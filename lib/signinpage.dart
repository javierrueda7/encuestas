import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/mainmenu.dart';
import 'package:forms_app/resetpassword.dart';
import 'package:forms_app/services/firebase_services.dart';
import 'package:forms_app/widgets/forms_widgets.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  List users = [];

  void obtainUsersList() async {
    users = await getUsuarios();
  }
  
  @override
  void initState() {
    super.initState();
    obtainUsersList();
  }

  final TextEditingController _passwordTextcontroller = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    obtainUsersList();
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromARGB(255, 244, 246, 252),
            Color.fromARGB(255, 222, 224, 227),
            Color.fromARGB(255, 222, 224, 227)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.1, 20, 0),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/LogoCyMA.png',
                      height: 250,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: buildEmailField('EMAIL', _emailTextController, false)
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: PasswordField(
                        label: 'CONTRASEÑA',
                        controller: _passwordTextcontroller,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: forgetPassword(context)),
                    const SizedBox(
                      height: 10,
                    ),
                    beAGuest(),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: firebaseButton(context, "INICIAR SESIÓN", () {
                          final email = _emailTextController.text;
                          final password = _passwordTextcontroller.text;
                          final userWithEmail = users.firstWhere(
                            (user) => user['email'] == email,
                            orElse: () => null,
                          );
                          if (userWithEmail != null &&
                                  userWithEmail['status'] == 'ACTIVO') {
                            // Allow login
                            FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password)
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Inicio de sesión satisfactorio.', style: TextStyle(color: Colors.black)),
                                  duration: Duration(seconds: 4),
                                  backgroundColor: Color.fromRGBO(52, 194, 64, 1),
                                ),
                              );
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainMenu()));
                            // ignore: sdk_version_since
                            }).onError((error, stackTrace) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sus datos no coinciden con nuestra información, verifíquelos o cree una cuenta.', style: TextStyle(color: Colors.white),),
                                  duration: Duration(seconds: 4),
                                  backgroundColor: Color.fromRGBO(214, 66, 66, 1),
                                ),
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sus datos no coinciden con nuestra información, verifíquelos o cree una cuenta.', style: TextStyle(color: Colors.white),),
                                duration: Duration(seconds: 4),
                                backgroundColor: Color.fromRGBO(214, 66, 66, 1),
                              ),
                            );
                          }
                        })),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: Text(
          "¿Olvidaste tu contraseña?",
          style: TextStyle(
              color: Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
          );
        },
      ),
    );
  }

  Row beAGuest() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
        onTap: () {
          FirebaseAuth.instance.signInAnonymously().then((value) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MainMenu()));
          // ignore: sdk_version_since
          }).onError((error, stackTrace) {});
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          height: 50,
          width: 300,
          child: Center(
            child: Text(
              "CONTINUAR SIN INICIAR SESIÓN",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ]);
  }
}