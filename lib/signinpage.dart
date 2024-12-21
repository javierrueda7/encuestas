// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/mainmenu.dart';
import 'package:forms_app/newuser.dart';
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
    users = await validLogin();
  }
  
  @override
  void initState() {
    super.initState();
    obtainUsersList();
  }

  void _reloadList() {
    setState(() {}); // Empty setState just to trigger rebuild
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
                      'assets/images/imagen.jpg',
                      height: 250,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text('SISTEMA DE ENCUESTAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    const SizedBox(
                      height: 20,
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
                    // beAGuest(),
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
                          print(1);
                          print(userWithEmail);
                          print (userWithEmail['status']);
                          String rol = userWithEmail['role'];
                          if (userWithEmail != null &&
                                  userWithEmail['status'] == 'ACTIVO') {
                                    print(2);
                            // Allow login
                            FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password)
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Bienvenid@ ${userWithEmail['name']}, inicio de sesión satisfactorio.', style: TextStyle(color: Colors.black)),
                                  duration: Duration(seconds: 4),
                                  backgroundColor: Color.fromRGBO(52, 194, 64, 1),
                                ),
                              );
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainMenu(role: rol, uid: userWithEmail['uid'])));
                            // ignore: sdk_version_since
                            }).onError((error, stackTrace) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tus datos no coinciden con nuestra información, verifícalos o crea una cuenta.', style: TextStyle(color: Colors.white),),
                                  duration: Duration(seconds: 4),
                                  backgroundColor: Color.fromRGBO(214, 66, 66, 1),
                                ),
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tus datos no coinciden con nuestra información, verifícalos o crea una cuenta.', style: TextStyle(color: Colors.white),),
                                duration: Duration(seconds: 4),
                                backgroundColor: Color.fromRGBO(214, 66, 66, 1),
                              ),
                            );
                          }
                        })),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),                                        
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddEditUser(reloadList: _reloadList, admin: false,);
                            }
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.amber;
                            }
                            return Colors.amber;
                          }),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)))),
                        child: Text('CREAR USUARIO', style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                      ),
                    ),
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
                MaterialPageRoute(builder: (context) => MainMenu(role: 'ANONIMO', uid: '')));
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
