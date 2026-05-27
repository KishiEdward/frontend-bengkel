import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/customer_model.dart';

class CustomerService {
  // =========================
  // GET ALL CUSTOMER
  // =========================
  Future<List<CustomerModel>> getAllCustomer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Sesi login habis");
    }

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/customers'),

      headers: {
        'Content-Type': 'application/json',

        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      List data = responseData['data'];

      return data.map((e) => CustomerModel.fromJson(e)).toList();
    }

    throw Exception("Gagal mengambil customer");
  }

  // =========================
  // CREATE CUSTOMER
  // =========================
  Future<bool> createCustomer({
    required String nama,
    required String alamat,
    required String noTelp,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Sesi login habis");
    }

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/customers'),

      headers: {
        'Content-Type': 'application/json',

        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({"nama": nama, "alamat": alamat, "no_telp": noTelp}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    }

    throw Exception("Gagal menambah customer");
  }
}
