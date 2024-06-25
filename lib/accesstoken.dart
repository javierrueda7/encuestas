import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

  const String clientId = '1000.5PEMG7QZ6VXGK5G7AA1SW7D9FSWB0M';
  const String clientSecret = '445c7746248907f802643979e42a7067f5b0a56226';
  const String scope = 'ZohoMail.messages.CREATE';
  const String redirectUri = 'https://cyma-encuestasmop.github.io/EncuestasMOP/';
  const String callbackUrlScheme = 'CyMA';
  const String accountId = '855887768'; // ID de cuenta de Zoho Mail

  Future<String> getAccessToken() async {
  try {
    const authorizationUrl = 'https://accounts.zoho.com/oauth/v2/auth?scope=$scope&client_id=$accountId&response_type=code&access_type=offline&redirect_uri=$redirectUri';

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

Future<void> sendZohoEmail({required String accessToken,
  required String fromEmail,
  required String toEmail,
  String? ccEmail,
  String? bccEmail,
  required String subject,
  required String content,
  String? askReceipt,
}) async {
  final url = Uri.parse('https://mail.zoho.com/api/accounts/855887768/messages'); // Replace with your account ID

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

void sendEmailSMTP() async {
  String username = 'javieruedase@zohomail.com'; // Your email
  String password = 'Boost0311'; // Your email account password

  final smtpServer = SmtpServer('smtp.zoho.com',
      username: username,
      password: password,
      port: 465); // Configure the SMTP server settings

  final message = Message()
    ..from = Address(username, 'Nombre de prueba')
    ..recipients.add('javieruedase@gmail.com') // Recipient email
    ..subject = 'Test Dart Mailer library :: 😀 :: ${DateTime.now()}'
    ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: $sendReport');
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}