import 'package:flutter/material.dart';
import 'package:forms_app/newuser.dart';

class InitPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  
  void _reloadList() {
    setState(() {}); // Empty setState just to trigger rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/LogoCyMA.png',
                height: 250,
              ),
              const SizedBox(
                height: 20,
              ),
              Text('SISTEMA DE ENCUESTAS MOP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              const SizedBox(
                height: 20,
              ),
              SizedBox(height: 30),
              /*ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainMenu()), // Navigate to the MainMenu
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('MENÚ PRINCIPAL'),
              ),
              SizedBox(height: 20),*/
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddEditUser(reloadList: _reloadList, admin: false,);
                    }
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('CREAR USUARIO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
