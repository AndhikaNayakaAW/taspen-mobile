import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = "https://api.taspen.co.id/ApiWebTaspen/public/api/";

  // Contoh: Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('${baseUrl}v2/loginAD');
    try {
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Contoh: Get Master Karyawan
  Future<Map<String, dynamic>> getMasterKaryawan() async {
    final url = Uri.parse('http://poprd.taspen.co.id:53000/RESTAdapter/masterkaryawan');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('APPHCIS:Hcisapp1!'))}',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch karyawan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
