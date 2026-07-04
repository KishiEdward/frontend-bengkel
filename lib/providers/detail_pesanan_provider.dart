import 'dart:io';

import 'package:flutter/material.dart';

import '../data/models/detail_pesanan_model.dart';
import '../data/services/pesanan_service.dart';

class DetailPesananProvider with ChangeNotifier {
  final PesananService _pesananService = PesananService();

  DetailPesananModel? _detailPesanan;
  bool _isLoading = false;
  String _errorMessage = '';

  DetailPesananModel? get detailPesanan => _detailPesanan;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // =========================
  // FETCH DETAIL PESANAN
  // =========================
  Future<void> fetchDetailPesanan(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _pesananService.getDetailPesanan(id);

      _detailPesanan = result;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // UPDATE STATUS
  // =========================
  Future<bool> ubahStatusPesanan(int pesananId, String status) async {
    try {
      bool success = await _pesananService.updateStatus(pesananId, status);

      if (success) {
        await fetchDetailPesanan(pesananId);
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // =========================
  // TAMBAH BIAYA
  // =========================
  Future<bool> tambahBiayaTakTerduga(
    int pesananId,
    String kategori,
    String keterangan,
    double nominal,
  ) async {
    try {
      bool success = await _pesananService.catatBiayaTambahan(
        pesananId,
        kategori,
        keterangan,
        nominal,
      );

      if (success) {
        await fetchDetailPesanan(pesananId);
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // =========================
  // CATAT PEMBAYARAN
  // =========================
  Future<bool> catatPembayaran(
    int pesananId,
    String tipe,
    double jumlah, {
    File? imageFile,
  }) async {
    try {
      // 1. Tembak API untuk catat pembayaran
      bool success = await _pesananService.catatPembayaran(
        pesananId,
        tipe,
        jumlah,
        imageFile: imageFile,
      );

      if (success) {
        // ==========================================
        // AUTO-UBAH STATUS JIKA LUNAS
        // ==========================================
        if (tipe.toLowerCase() == 'lunas') {
          // Tembak API update status menjadi 'Selesai'
          await _pesananService.updateStatus(pesananId, 'Selesai');
        }

        // 2. Tarik ulang data detail terbaru untuk me-refresh layar
        await fetchDetailPesanan(pesananId);
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
