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

  Future<void> fetchLaporan() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _laporanData = await _pesananService.getLaporanKeuangan();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
