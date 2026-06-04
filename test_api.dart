import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent?alt=sse');
  final request = http.Request('POST', uri);
  request.headers['Content-Type'] = 'application/json';
  request.headers['x-goog-api-key'] = "Ab8RN6ICU6NcCoT9_RCve8X4RiQ92u_ZWpC29GQsTKqNUniIcA";
  request.body = jsonEncode({
    "contents": [{"parts": [{"text": "hello"}]}]
  });

  final response = await http.Client().send(request);
  print('Status: ${response.statusCode}');
  final body = await response.stream.bytesToString();
  print('Body: $body');
}
