import 'package:flutter/material.dart';
import '../data/models/pesanan_model.dart';
import '../data/services/pesanan_service.dart';

class PesananProvider with ChangeNotifier {
  final PesananService _pesananService = PesananService();

  List<Pesanan> _listPesanan = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Pesanan> get listPesanan => _listPesanan;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fungsi ini dipanggil saat halaman dibuka atau saat layar ditarik (Pull-to-refresh)
  Future<void> fetchPesanan() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _listPesanan = await _pesananService.getSemuaPesanan();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi submit form
  Future<bool> tambahPesanan(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _pesananService.createPesanan(data);
      if (success) {
        // Jika sukses, tarik ulang data terbaru dari backend
        await fetchPesanan();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
