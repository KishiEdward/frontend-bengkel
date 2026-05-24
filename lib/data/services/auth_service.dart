import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // 1. FUNGSI BARU: REGISTRASI & KIRIM EMAIL VERIFIKASI
  Future<bool> register(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Setelah berhasil terdaftar, langsung kirim email verifikasi
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }
      return true;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Gagal mendaftar");
    }
  }

  // 2. MODIFIKASI FUNGSI LOGIN
  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // CEK STATUS VERIFIKASI DI SINI
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        // Jika belum verifikasi, kirim ulang emailnya (opsional) lalu tolak login
        await userCredential.user!.sendEmailVerification();
        // Logout otomatis dari Firebase agar status ter-reset
        await _firebaseAuth.signOut();
        throw Exception(
          "Email belum diverifikasi! Silakan cek kotak masuk/spam email Anda untuk link verifikasi.",
        );
      }

      // Jika sudah diverifikasi, lanjut minta token ke Golang (Kode lama tetap sama)
      String? firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) {
        throw Exception("Gagal mendapatkan Firebase Token");
      }

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebase_token': firebaseToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String jwtToken = data['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwtToken);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Gagal login ke server lokal");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fungsi Reset Password (sudah kita buat sebelumnya)
  Future<bool> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      throw Exception(
        "Gagal mengirim tautan. Pastikan email terdaftar dan valid.",
      );
    }
  }
}
