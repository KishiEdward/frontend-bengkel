import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../models/pesanan_model.dart';
import '../models/detail_pesanan_model.dart';

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
  Future<DetailPesananModel> getDetailPesanan(int id) async {
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

      return DetailPesananModel.fromJson(responseData['data']);
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

  // Fungsi ubah status pesanan
  Future<bool> updateStatus(int id, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/pesanan/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"status": status}),
    );
    return response.statusCode == 200;
  }

  // Fungsi catat pengeluaran tak terduga
  Future<bool> catatBiayaTambahan(
    int pesananId,
    String kategori,
    String keterangan,
    double nominal,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/biaya-tambahan'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({
        "pesanan_id": pesananId,
        "kategori": kategori,
        "keterangan": keterangan,
        "nominal": nominal,
      }),
    );

    return response.statusCode == 201;
  }

  // Fungsi catat pembayaran (DP / Lunas)
  Future<bool> catatPembayaran(
    int pesananId,
    String tipe,
    double jumlah, {
    File? imageFile,
  }) async {
    // 1. Ambil token dari brankas lokal
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token == null) throw Exception("Sesi telah habis.");

    // PASTIKAN TIDAK ADA /v1 DI SINI
    final url = Uri.parse('${AppConstants.baseUrl}/pembayaran');
    print("MENGIRIM KE URL: $url"); // Melacak URL

    // 2. Gunakan MultipartRequest
    var request = http.MultipartRequest('POST', url);

    // 3. PASANG TOKEN DI HEADER
    request.headers['Authorization'] = 'Bearer $token';

    // 4. Masukkan data teks ke fields
    request.fields['pesanan_id'] = pesananId.toString();
    request.fields['tipe'] = tipe;
    request.fields['jumlah'] = jumlah.toString();
    request.fields['tgl'] = DateTime.now().toUtc().toIso8601String();

    // 5. Masukkan gambar jika file-nya ada
    if (imageFile != null) {
      print("MENGIRIM GAMBAR: ${imageFile.path}");
      request.files.add(
        await http.MultipartFile.fromPath('bukti_bayar', imageFile.path),
      );
    } else {
      print("TIDAK ADA GAMBAR YANG DIKIRIM");
    }

    // 6. Eksekusi request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // MELACAK PESAN ERROR DARI GOLANG
    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 201) {
      return true;
    } else {
      // Menangkap pesan error langsung dari backend
      var errorMsg = "Gagal mencatat pembayaran";
      try {
        final errorData = jsonDecode(response.body);
        errorMsg = errorData['message'] ?? errorMsg;
      } catch (e) {
        errorMsg = response.body; // Jika bukan JSON
      }
      throw Exception(errorMsg);
    }
  }

  // Fungsi untuk menarik laporan keuangan global
  Future<Map<String, dynamic>> getLaporanKeuangan({
    String bulan = 'Semua',
    String tahun = 'Semua',
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    // Tempelkan variabel bulan dan tahun ke akhir URL
    final response = await http.get(
      Uri.parse(
        '${AppConstants.baseUrl}/pesanan/laporan?bulan=$bulan&tahun=$tahun',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['data'];
    } else {
      throw Exception("Gagal menarik data laporan keuangan");
    }
  }
}
