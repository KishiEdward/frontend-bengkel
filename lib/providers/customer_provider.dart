import 'package:flutter/material.dart';

import '../data/models/customer_model.dart';
import '../data/services/customer_service.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<CustomerModel> _listCustomer = [];

  bool _isLoading = false;

  String _errorMessage = '';

  List<CustomerModel> get listCustomer => _listCustomer;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  // =========================
  // FETCH CUSTOMER
  // =========================
  Future<void> fetchCustomer() async {
    _isLoading = true;

    notifyListeners();

    try {
      _listCustomer = await _customerService.getAllCustomer();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =========================
  // CREATE CUSTOMER
  // =========================
  Future<bool> tambahCustomer({
    required String nama,
    required String alamat,
    required String noTelp,
  }) async {
    try {
      bool sukses = await _customerService.createCustomer(
        nama: nama,
        alamat: alamat,
        noTelp: noTelp,
      );

      if (sukses) {
        await fetchCustomer();
      }

      return sukses;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }
}
