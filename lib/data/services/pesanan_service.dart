import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../models/pesanan_model.dart';

class PesananService {
  Future<List<Pesanan>> getSemuaPesanan() async {
    // 1. Ambil token dari brankas lokal HP
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Sesi telah habis, silakan login kembali.");
    }

    // 2. Tembak API Golang dengan membawa Token
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/pesanan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // <-- INI KUNCI PINTUNYA!
      },
    );

    // 3. Proses Datanya
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> dataList = responseData['data'];

      // Ubah list JSON menjadi list Objek Pesanan
      return dataList.map((json) => Pesanan.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data pesanan");
    }
  }

  // Mengambil detail pesanan beserta kalkulasi margin dari backend
  Future<Map<String, dynamic>> getDetailPesanan(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Sesi telah habis, silakan login kembali.");
    }

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/pesanan/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // Backend mengembalikan { data: { pesanan: {...}, keuangan: {...} } }
      return responseData['data'];
    } else {
      throw Exception("Gagal mengambil detail pesanan");
    }
  }

  // Fungsi untuk mengirim data pesanan baru ke Golang
  Future<bool> createPesanan(Map<String, dynamic> dataPesanan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) throw Exception("Sesi telah habis.");

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/pesanan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dataPesanan),
    );

    if (response.statusCode == 201) {
      return true; // 201 Created
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? "Gagal membuat pesanan");
    }
  }
}
