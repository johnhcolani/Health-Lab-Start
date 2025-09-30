import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientService {
  // Public HAPI test server (R4)
  static const _base = 'https://hapi.fhir.org/baseR4';

  static Future<List<Map<String, dynamic>>> fetchPatients({int count = 20}) async {
    final uri = Uri.parse('$_base/Patient?_count=$count');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('FHIR fetch failed: ${res.statusCode}');
    }
    final json = jsonDecode(res.body);
    final entries = json['entry'] as List<dynamic>? ?? [];
    final patients = entries.map((e) => e['resource'] as Map<String, dynamic>).toList();
    return patients;
  }

  static String getDisplayName(Map<String, dynamic> patient) {
    // Try to build display name from name array
    final names = patient['name'] as List<dynamic>?;
    if (names != null && names.isNotEmpty) {
      final first = names.first as Map<String, dynamic>;
      final given = (first['given'] as List<dynamic>?)?.join(' ') ?? '';
      final family = first['family'] ?? '';
      final display = '$given ${family}'.trim();
      if (display.isNotEmpty) return display;
    }
    // fallback id or text
    return patient['id'] ?? (patient['text'] != null ? patient['text']['div'] : 'Unnamed');
  }
}