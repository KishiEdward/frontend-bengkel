import 'package:flutter/material.dart';
import '../data/services/pesanan_service.dart';

class DetailPesananProvider with ChangeNotifier {
  final PesananService _pesananService = PesananService();

  Map<String, dynamic>? _detailData;
  bool _isLoading = false;
  String _errorMessage = '';

  Map<String, dynamic>? get detailData => _detailData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchDetailPesanan(int id) async {
    _isLoading = true;
    _errorMessage = '';
    // Kosongkan data lama agar tidak muncul saat buka pesanan lain
    _detailData = null;
    notifyListeners();

    try {
      _detailData = await _pesananService.getDetailPesanan(id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
