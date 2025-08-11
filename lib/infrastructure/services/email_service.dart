import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  Future<bool> sendRecoveryEmail(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          "service_id": dotenv.env['EMAILJS_SERVICE_ID'],
          "template_id": dotenv.env['EMAILJS_TEMPLATE_ID'],
          "user_id": dotenv.env['EMAILJS_USER_ID'],
          "template_params": {
            "email": email,
            "code": code,
          }
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error sending email: $e");
      return false;
    }
  }
}
