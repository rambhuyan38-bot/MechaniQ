import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CloudflareAIService {
  // Singleton Pattern: ऐप में सर्विस का एक ही इंस्टेंस रखने के लिए
  static final CloudflareAIService _instance = CloudflareAIService._internal();
  factory CloudflareAIService() => _instance;
  CloudflareAIService._internal();

  // आपके द्वारा दिए गए असली Cloudflare Worker का URL और Secret Key
  final String _workerUrl = 'https://rough-block-3dd9.rambhuyan23.workers.dev/analyze';
  final String _appSecret = 'MechaniQ_Secure_Key_2026_!@#';

  /// यह फंक्शन OBD डेटा को लेगा, उसे JSON में बदलेगा और AI को भेजेगा
  Future<String> getAIDiagnosis(Map<String, dynamic> obdData) async {
    try {
      debugPrint("Sending OBD Data to Cloudflare AI Worker...");
      
      final response = await http.post(
        Uri.parse(_workerUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': _appSecret, // सुरक्षा के लिए आपका कस्टम हेडर
        },
        body: jsonEncode(obdData),
      );

      // अगर सर्वर ने सही जवाब दिया (Status Code 200)
      if (response.statusCode == 200) {
        debugPrint("AI Response Received Successfully!");
        
        // मान लेते हैं कि आपका Worker JSON फॉर्मेट में जवाब दे रहा है, जैसे: {"result": "AI diagnosis text..."}
        // अगर Worker सीधा टेक्स्ट (String) भेजता है, तो आप डायरेक्ट `response.body` रिटर्न कर सकते हैं।
        try {
          final responseData = jsonDecode(response.body);
          return responseData['result'] ?? responseData['analysis'] ?? response.body;
        } catch (e) {
          // अगर रिस्पॉन्स JSON नहीं, बल्कि सादा टेक्स्ट है
          return response.body;
        }
      } else {
        // अगर पासवर्ड गलत है या सर्वर में कोई दिक्कत है
        debugPrint("Cloudflare Server Error: \${response.statusCode}");
        return "System Error: Unable to analyze data. Server returned status \${response.statusCode}.";
      }
    } catch (e) {
      // इंटरनेट या नेटवर्क की कोई समस्या होने पर
      debugPrint("Cloudflare API Connection Error: \$e");
      return "Connection Error: Failed to reach the AI server. Please check your internet connection.";
    }
  }
}
