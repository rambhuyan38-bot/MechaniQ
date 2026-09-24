import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudflareAIService {
  // New Secure Cloudflare Worker URL
  static const String _workerUrl = 'https://rough-block-3dd9.rambhuyan23.workers.dev/analyze';
  
  // Security Key to bypass Cloudflare 403 Forbidden
  static const String _appSecret = 'MechaniQ_Secure_Key_2026_!@#';

  Future<Map<String, dynamic>> analyzeFault(Map<String, dynamic> obdData) async {
    try {
      final response = await http.post(
        Uri.parse(_workerUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': _appSecret,
        },
        body: jsonEncode(obdData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode} -${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to MechaniQ AI Server: $e');
    }
  }
}