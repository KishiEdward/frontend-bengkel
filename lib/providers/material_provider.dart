import 'package:flutter/material.dart';

import '../data/models/material_model.dart';
import '../data/services/material_service.dart';

class MaterialProvider with ChangeNotifier {
  final MaterialService _materialService = MaterialService();

  List<MaterialModel> _listMaterial = [];

  bool _isLoading = false;

  String _errorMessage = '';

  List<MaterialModel> get listMaterial => _listMaterial;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  // =========================
  // FETCH MATERIAL
  // =========================
  Future<void> fetchMaterial() async {
    _isLoading = true;

    notifyListeners();

    try {
      _listMaterial = await _materialService.getAllMaterial();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =========================
  // CREATE MATERIAL
  // =========================
  Future<bool> tambahMaterial({
    required String nama,
    required String satuan,
    required double hargaDefault,
  }) async {
    try {
      bool sukses = await _materialService.createMaterial(
        nama: nama,
        satuan: satuan,
        hargaDefault: hargaDefault,
      );

      if (sukses) {
        await fetchMaterial();
      }

      return sukses;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }
}
