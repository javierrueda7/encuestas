import 'package:flutter/material.dart';
import 'package:forms_app/mainmenu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:forms_app/newuser.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that widget binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainMenu()), // Navigate to the MainMenu
                );
              },
              child: Text('MENÚ PRINCIPAL'),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddEditUser(reloadList: _reloadList, admin: false,);
                  }
                );
              },
              child: Text('CREAR USUARIO'),
            ),
          ],
        ),
      ),
    );
  }
}
