import 'package:flutter/material.dart';
import '../data/services/pesanan_service.dart';

class LaporanProvider with ChangeNotifier {
  final PesananService _pesananService = PesananService();

  Map<String, dynamic>? _laporanData;
  bool _isLoading = false;
  String _errorMessage = '';

  Map<String, dynamic>? get laporanData => _laporanData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Parameter bulan dan tahun ditambahkan di sini
  Future<void> fetchLaporan({
    String bulan = 'Semua',
    String tahun = 'Semua',
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Mengirimkan bulan dan tahun ke service
      _laporanData = await _pesananService.getLaporanKeuangan(
        bulan: bulan,
        tahun: tahun,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
