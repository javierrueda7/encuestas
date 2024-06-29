import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:forms_app/accesstoken.dart';
import 'package:forms_app/listforms.dart';
import 'package:forms_app/listparam.dart';
import 'package:forms_app/listusers.dart';
import 'package:forms_app/userforms.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class MainMenu extends StatefulWidget {
  final String? role;
  final String? uid;
  MainMenu({super.key, required this.role, required this.uid});
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String role = 'ANON';
  String uid = '';

  @override
  void initState() {
    super.initState();
    role = widget.role ?? role;
    uid = widget.uid ?? uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('CYMA - ENCUESTAS MOP')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: role != 'ADMINISTRADOR',
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListUserForms(uid: uid)),
                      );
                    },
                    child: Text('RESPONDER ENCUESTA'),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: role != 'USUARIO',
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListFormsScreen()),
                      );
                    },
                    child: Text('ADMINISTRAR ENCUESTAS'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListUsersScreen()),
                      );
                    },
                    child: Text('ADMINISTRAR USUARIOS'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListParameterScreen(param: 'Proyectos')),
                      );
                    },
                    child: Text('ADMINISTRAR PROYECTOS'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListParameterScreen(param: 'Actividades')),
                      );
                    },
                    child: Text('ADMINISTRAR ACTIVIDADES'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListParameterScreen(param: 'Cargos')),
                      );
                    },
                    child: Text('ADMINISTRAR CARGOS'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final accessToken = await getAccessToken();
                        await sendZohoEmail(
                          accessToken: accessToken,
                          fromEmail: 'javieruedase@zohomail.com',
                          toEmail: 'javieruedase@gmail.com',
                          subject: 'Prueba de correo',
                          content: 'contenido',
                        );
                      } catch (e) {
                        print('Error: $e');
                      }
                    },
                    child: Text('Enviar correo'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListParameterScreen(param: 'Profesiones')),
                      );
                    },
                    child: Text('ADMINISTRAR PROFESIONES'),
                  ),
                  Visibility(
                    visible: role != 'USUARIO',
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            html.window.open(
                              "https://app.powerbi.com/view?r=eyJrIjoiMzBiZGZjMGYtMjJlMy00NDhiLThlODUtNmE3Mzk3NjA1MWM2IiwidCI6IjJlZDU1NzRjLWY5YmEtNDQyNi05NjU4LWU0NzdhZDc0MzlkYiIsImMiOjR9",
                              '_blank',
                            );
                          },
                          child: Text('CONSULTAS'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const String clientId = '1000.LJ685O4V2A3WG4C5KVHJL1HC12J54S';
  static const String clientSecret = 'b9bc37b1794fb1ade28605387d665fa7a515199685';
  static const String scope = 'ZohoMail.messages.CREATE';
  static const String redirectUri = 'https://cyma-encuestasmop.github.io/EncuestasMOP/';
  static const String callbackUrlScheme = 'cyma';
  static const String accountId = '855887768';

  Future<String> getAccessToken() async {
    try {
      const authorizationUrl = 'https://accounts.zoho.com/oauth/v2/auth?scope=$scope&client_id=$clientId&response_type=code&access_type=offline&redirect_uri=$redirectUri';

      print('Launching authorization URL: $authorizationUrl');
      final result = await FlutterWebAuth.authenticate(
        url: authorizationUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      print('Authentication result: $result');

      final code = Uri.parse(result).queryParameters['code'];

      if (code == null) {
        throw Exception('Authorization code not found in callback.');
      }

      const tokenUrl = 'https://accounts.zoho.com/oauth/v2/token';
      final response = await http.post(
        Uri.parse(tokenUrl),
        body: {
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
          'code': code,
        },
      );

      final accessToken = jsonDecode(response.body)['access_token'];
      print('Access Token: $accessToken');
      return accessToken;
    } catch (e) {
      print('Error in authentication: $e');
      throw Exception('Failed to authenticate with Zoho: $e');
    }
  }

  Future<void> sendZohoEmail({
    required String accessToken,
    required String fromEmail,
    required String toEmail,
    String? ccEmail,
    String? bccEmail,
    required String subject,
    required String content,
    String? askReceipt,
  }) async {
    final url = Uri.parse('https://mail.zoho.com/api/accounts/$accountId/messages');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Zoho-oauthtoken $accessToken',
    };

    final body = jsonEncode({
      'fromAddress': fromEmail,
      'toAddress': toEmail,
      'ccAddress': ccEmail ?? '',
      'bccAddress': bccEmail ?? '',
      'subject': subject,
      'content': content,
      'askReceipt': askReceipt ?? '',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Email sent successfully');
      } else {
        print('Failed to send email: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
