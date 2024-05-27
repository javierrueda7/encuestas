import 'package:flutter/material.dart';
import 'package:forms_app/mainmenu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:forms_app/newuser.dart';
import 'firebase_options.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(EncuestasMOP());
}
  

class EncuestasMOP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CYMA - ENCUESTAS MOP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(), // Use the MainPage as the home page
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  void _reloadList() {
    setState(() {}); // Empty setState just to trigger rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('INICIO')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'LogoCyMA.png',
                height: 250,
              ),
              SizedBox(height: 30),
              ElevatedButton(
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
              SizedBox(height: 20),
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
