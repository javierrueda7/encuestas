import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

  const String clientId = '1000.V3DYQA2NFX23Z4WA1YBVBA6OO4LZUK';
  const String clientSecret = '7b1825524f8292f62f1843155c4b794b5057fec5b1';
  const String redirectUri = 'http://localhost:3000/zoho/oauth/callback';
  const String callbackUrlScheme = 'myflutterapp';
  const String accountId = '855887768'; // ID de cuenta de Zoho Mail

  Future<String> getAccessToken() async {
  try {
    const authorizationUrl = 'https://accounts.zoho.com/oauth/v2/auth'
        '?response_type=code'
        '&client_id=$clientId'
        '&scope=ZohoMail.messages.CREATE'
        '&redirect_uri=$redirectUri';

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
