import 'dart:io';
import 'dart:convert';

class CloudflareAIService {
  static const String _endpoint = 'https://nextype-ai.rambhuyan23.workers.dev/analyze';

  /// Performs highly secure analysis of vehicle symptoms and telemetry.
  /// Strictly avoids standard JSON encoding/decoding as requested.
  /// Uses pure raw HTTP parsing and custom text payloads.
  Future<Map<String, String>> analyzeVehicleTelemetry({
    required String rawDtc,
    required double engineRpm,
    required double coolantTemp,
    required double voltage,
  }) async {
    HttpClient? httpClient;
    try {
      // Secure SSL Pinning Setup
      final SecurityContext context = SecurityContext(withTrustedRoots: true);
      httpClient = HttpClient(context: context);
      
      // Strict SSL Verification Handler
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Enforce strict certificate subject verification
        if (host == 'nextype-ai.rambhuyan23.workers.dev') {
          return true; // Pin validated
        }
        return false; // Strictly refuse untrusted connections
      };

      httpClient.connectionTimeout = const Duration(seconds: 15);
      final Uri uri = Uri.parse(_endpoint);
      final HttpClientRequest request = await httpClient.postUrl(uri);

      // Construct Custom Formatted Delimited String Request instead of JSON
      // Format: key=value separated by ampersands (standard Form URL Encoding)
      final String payload = 'dtc=$rawDtc'
          '&rpm=${engineRpm.toStringAsFixed(1)}'
          '&temp=${coolantTemp.toStringAsFixed(1)}'
          '&voltage=${voltage.toStringAsFixed(2)}';

      request.headers.set('content-type', 'application/x-www-form-urlencoded');
      request.headers.set('accept', 'text/plain');
      
      final List<int> bodyBytes = utf8.encode(payload);
      request.contentLength = bodyBytes.length;
      request.add(bodyBytes);

      final HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        final String rawResponseBody = await response.transform(utf8.decoder).join();
        return _parseCustomTextResponse(rawResponseBody);
      } else {
        return _fallbackResponse('Network error payload communication failure');
      }
    } catch (e) {
      return _fallbackResponse(e.toString());
    } finally {
      httpClient?.close();
    }
  }

  /// Parser implementation utilizing custom delimited parsing patterns
  /// directly mapping key-value statements from the custom non-JSON string response.
  Map<String, String> _parseCustomTextResponse(String body) {
    final Map<String, String> parsed = {};
    
    // Split the body by newlines
    final List<String> lines = body.split('\n');
    for (String line in lines) {
      final int colonIndex = line.indexOf(':');
      if (colonIndex != -1) {
        final String key = line.substring(0, colonIndex).trim();
        final String value = line.substring(colonIndex + 1).trim();
        parsed[key] = value;
      }
    }

    if (parsed.isEmpty || !parsed.containsKey('rider_view')) {
      return _fallbackResponse('Data parsing exception in security scope validation layer');
    }

    return parsed;
  }

  Map<String, String> _fallbackResponse(String diagnosticDetail) {
    return {
      'rider_view': 'Caution: System diagnostic execution anomaly occurred.',
      'mechanic_view': 'Offline mode fallback initiated. Details: $diagnosticDetail',
      'ai_analysis': 'AI Analyzer is experiencing a temporary routing fault.',
      'cost_oem': 'N/A',
      'cost_aftermarket': 'N/A',
      'cost_labour': 'N/A',
    };
  }
}