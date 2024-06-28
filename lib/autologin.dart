// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/mainmenu.dart';
import 'package:forms_app/services/firebase_services.dart';
import 'package:forms_app/widgets/forms_widgets.dart';

class AutoLogin extends StatefulWidget {
  const AutoLogin({super.key});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> {
  List users = [];

  void obtainUsersList() async {
    users = await validLogin();
  }
  
  
  void _reloadList() {
    setState(() {}); // Empty setState just to trigger rebuild
  }
  
  @override
  void initState() {
    super.initState();
    obtainUsersList();
  }

  @override
  Widget build(BuildContext context) {
    obtainUsersList();
    return firebaseButton(context, "INICIAR SESIÓN", () {
      const email = 'javieruedase@gmail.com';
      const password = '123456';
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
    });
  }

  autoLoginFn() async {
    users = await validLogin();
    const email = 'javieruedase@gmail.com';
    const password = '123456';
    final userWithEmail = users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => null,
    );
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
  }

}
