import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> login(String email, String password) async {
    try {
      // 1. Verifikasi Email & Password ke Firebase Google
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // 2. Jika berhasil, minta ID Token Firebase
      String? firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) {
        throw Exception("Gagal mendapatkan Firebase Token");
      }

      // 3. Kirim Firebase Token ke Backend Golang kita
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebase_token': firebaseToken}),
      );

      // 4. Proses balasan dari Golang
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String jwtToken = data['token']; // Ambil JWT Stempel Bengkel

        // Simpan JWT di brankas lokal HP agar tidak perlu login terus
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwtToken);

        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Gagal login ke server lokal");
      }
    } catch (e) {
      // Tangkap error (misal: password salah, server mati)
      rethrow;
    }
  }
}
