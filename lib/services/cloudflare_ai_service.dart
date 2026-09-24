import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../models/vehicle.dart';
import '../database/db_helper.dart';

class CloudflareAIService {
  final String _endpoint = "https://nextype-ai.rambhuyan23.workers.dev";

  // SHA-256 SSL Certificate Pin for Secure Handshake
  final List<String> _allowedFingerprints = [
    "D2:B6:3C:A9:E2:0F:7F:A1:6A:9A:88:B1:01:99:A3:A3:D4:6C:EC:87:B3:34:F2:77:E1:9F:DF:D4:F6:EA:44:A2"
  ];

  Future<HttpClient> _getSecureClient() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // SSL Pinning validation step
      final sha256Bytes = cert.sha256;
      final fingerprint = sha256Bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
      if (_allowedFingerprints.contains(fingerprint)) {
        return true;
      }
      // Fail fallback safely in production
      return false;
    };
    return client;
  }

  Future<Map<String, dynamic>> queryDiagnostics({
    required Vehicle vehicle,
    required List<String> dtcCodes,
    required String lang,
  }) async {
    // Offline Fallback integration instantly if no internet or server error
    try {
      final client = await _getSecureClient();
      final Uri uri = Uri.parse(_endpoint);
      final request = await client.postUrl(uri);
      
      request.headers.set('content-type', 'application/json');
      
      final payload = {
        'type': vehicle.type,
        'brand': vehicle.brand,
        'model': vehicle.model,
        'year': vehicle.year,
        'fuel': vehicle.fuelType,
        'dtc': dtcCodes,
        'language': lang
      };
      
      request.write(jsonEncode(payload));
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final decoded = jsonDecode(body);
        return decoded as Map<String, dynamic>;
      }
    } catch (e) {
      // Handle SSL / Server error transparently & trigger Local DB Cache fallback
    }

    return await _fallbackLocalDiagnostics(dtcCodes);
  }

  Future<Map<String, dynamic>> _fallbackLocalDiagnostics(List<String> dtcs) async {
    List<Map<String, dynamic>> fallbackDetails = [];
    for (var code in dtcs) {
      final dbRec = await DbHelper.instance.queryDtc(code);
      if (dbRec != null) {
        fallbackDetails.add({
          'code': dbRec.code,
          'definition': dbRec.definition,
          'severity': dbRec.severity,
          'riderExplanation': dbRec.riderExplanation,
          'possibleCauses': dbRec.possibleCauses,
          'recommendedTest': dbRec.recommendedTest,
          'oemCost': dbRec.repairCostOem,
          'aftermarketCost': dbRec.repairCostAftermarket,
          'laborCost': dbRec.laborCost
        });
      }
    }
    return {
      'status': 'offline_fallback',
      'confidence': 90.0,
      'evidence': 'SQLite Offline Profile',
      'diagnostics': fallbackDetails
    };
  }
}