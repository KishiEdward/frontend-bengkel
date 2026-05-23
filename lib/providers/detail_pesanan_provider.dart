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

  Future<bool> ubahStatusPesanan(int id, String statusBaru) async {
    _isLoading = true;
    notifyListeners();
    try {
      bool success = await _pesananService.updateStatus(id, statusBaru);
      if (success) {
        await fetchDetailPesanan(id); // Langsung refresh data terbaru
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tambahBiayaTakTerduga(
    int id,
    String keterangan,
    double nominal,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      bool success = await _pesananService.catatBiayaTambahan(
        id,
        keterangan,
        nominal,
      );
      if (success) {
        await fetchDetailPesanan(id); // Langsung refresh HPP dan Margin
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
