// lib/services/api_service_easy_taspen.dart

import 'package:http/http.dart' as http;
import 'package:mobileapp/dto/create_duty_response.dart';
import 'package:mobileapp/dto/get_duty_list.dart';
import 'dart:convert';
import '../dto/login_response.dart';
import '../dto/base_response.dart';

class ApiService {
  final String baseUrl =
      "https://c24fccc8-e0f8-4bd9-935c-1b5ac4edbd72.mock.pstmn.io";

  // Login Method
  Future<LoginResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/gateway/loginAD/1.0/ApiLoginADPublic');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Ensure 'status' key exists in the response
        if (!responseBody.containsKey('status')) {
          throw Exception('Invalid response structure: Missing "status" key.');
        }

        return LoginResponse.fromJson(responseBody);
      } else {
        // Extract error message from response if available
        String errorMsg = 'Failed to login: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          if (errorResponse.containsKey('status') &&
              errorResponse['status'].containsKey('TEXT')) {
            errorMsg = errorResponse['status']['TEXT'];
          }
        } catch (_) {
          // Ignore JSON parsing errors for error responses
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Login Error: $e');
    }
  }

  Future<BaseResponse<GetDutyList>> fetchDuties(
      String nik, String kodeJabatan) async {
    final url = Uri.parse('$baseUrl/devops-easy/src/public/api/duty/index');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nik': nik,
          'kodejabatan': kodeJabatan,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['metadata']['code'] == 200) {
          return BaseResponse<GetDutyList>.fromJson(
              responseBody, GetDutyList.fromJson);
        } else {
          throw Exception(
              responseBody['metadata']['message'] ?? 'Failed to fetch duties.');
        }
      } else {
        throw Exception('Failed to fetch duties: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching duties: $e');
    }
  }

  Future<BaseResponse<CreateDutyResponse>> createDuty({
    required String nik,
    required String orgeh,
    required String ba,
  }) async {
    final url = Uri.parse('$baseUrl/devops-easy/src/public/api/duty/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers, e.g., Authorization if needed
        },
        body: jsonEncode({
          'NIK': nik,
          'ORGEH': orgeh,
          'BA': ba,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['metadata']['code'] == 200) {
          return BaseResponse<CreateDutyResponse>.fromJson(
              responseBody, CreateDutyResponse.fromJson);
        } else {
          throw Exception(
              responseBody['metadata']['message'] ?? 'Failed to create duty.');
        }
      } else {
        throw Exception('Failed to create duty: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating duty: $e');
    }
  }

  // Get Master Karyawan Method
  Future<Map<String, dynamic>> getMasterKaryawan() async {
    final url =
        Uri.parse('http://poprd.taspen.co.id:53000/RESTAdapter/masterkaryawan');
    try {
      final response = await http.get(url, headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('APPHCIS:Hcisapp1!'))}',
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
