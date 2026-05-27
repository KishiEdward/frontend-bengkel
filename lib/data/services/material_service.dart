import 'dart:convert';

import 'package:front_bengkel/core/constants.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/material_model.dart';

class MaterialService {
  // =========================
  // GET ALL MATERIAL
  // =========================
  Future<List<MaterialModel>> getAllMaterial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Sesi login habis");
    }

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/materials'),

      headers: {
        'Content-Type': 'application/json',

        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      List data = responseData['data'];

      return data.map((e) => MaterialModel.fromJson(e)).toList();
    }

    throw Exception("Gagal mengambil material");
  }

  // =========================
  // CREATE MATERIAL
  // =========================
  Future<bool> createMaterial({
    required String nama,
    required String satuan,
    required double hargaDefault,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Sesi login habis");
    }

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/materials'),

      headers: {
        'Content-Type': 'application/json',

        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({
        "nama": nama,
        "satuan": satuan,
        "harga_default": hargaDefault,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    }

    throw Exception("Gagal menambah material");
  }
}
