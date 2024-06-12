import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:forms_app/firebase_options.dart';
import 'package:forms_app/signinpage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Pages

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [Locale('es'), Locale('en')],
      title: 'CYMA - ENCUESTAS MOP',
      initialRoute: '/',
      routes: {
        '/': (context) => SignInPage(),
      },
    );
  }
}
