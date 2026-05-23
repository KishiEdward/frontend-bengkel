import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pesanan_provider.dart';

class TambahPesananScreen extends StatefulWidget {
  const TambahPesananScreen({super.key});

  @override
  State<TambahPesananScreen> createState() => _TambahPesananScreenState();
}

class _TambahPesananScreenState extends State<TambahPesananScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk Customer
  final _namaCustomerCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _noTelpCtrl = TextEditingController();

  // Controllers untuk Pesanan & Material
  final _hargaJualCtrl = TextEditingController();
  final _namaMaterialCtrl = TextEditingController();
  final _qtyMaterialCtrl = TextEditingController();
  final _hargaMaterialCtrl = TextEditingController();

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Menyusun JSON persis seperti yang diminta Backend Golang
    final payload = {
      "customer": {
        "nama": _namaCustomerCtrl.text,
        "alamat": _alamatCtrl.text,
        "no_telp": _noTelpCtrl.text,
      },
      "tgl_order": DateTime.now().toIso8601String(), // Otomatis hari ini
      "tgl_deadline": DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(), // Default +7 Hari
      "harga_jual": double.parse(_hargaJualCtrl.text),
      "status": "Menunggu DP",
      "pesanan_material": [
        {
          "material": {
            "nama": _namaMaterialCtrl.text,
            "qty": int.parse(_qtyMaterialCtrl.text),
            "harga": double.parse(_hargaMaterialCtrl.text),
          },
          "qty": int.parse(_qtyMaterialCtrl.text),
          "harga_satuan": double.parse(_hargaMaterialCtrl.text),
        },
      ],
    };

    final provider = Provider.of<PesananProvider>(context, listen: false);
    bool success = await provider.tambahPesanan(payload);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pesanan berhasil ditambahkan!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Kembali ke Dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF005088),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<PesananProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Input Pesanan Baru",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005088),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle("1. Data Pelanggan"),
            TextFormField(
              controller: _namaCustomerCtrl,
              decoration: const InputDecoration(
                labelText: "Nama Perusahaan/Klien",
                border: OutlineInputBorder(),
              ),
              validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _alamatCtrl,
              decoration: const InputDecoration(
                labelText: "Alamat",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noTelpCtrl,
              decoration: const InputDecoration(
                labelText: "No. Telepon",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),

            _buildSectionTitle("2. Detail Finansial & Material"),
            TextFormField(
              controller: _hargaJualCtrl,
              decoration: const InputDecoration(
                labelText: "Harga Jual Proyek (Rp)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kebutuhan Material Dasar:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _namaMaterialCtrl,
                      decoration: const InputDecoration(
                        labelText: "Nama Material (mis: Baja S45C)",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _qtyMaterialCtrl,
                            decoration: const InputDecoration(
                              labelText: "Jumlah (Qty)",
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _hargaMaterialCtrl,
                            decoration: const InputDecoration(
                              labelText: "Harga Satuan (Rp)",
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF11caa0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      "SIMPAN PESANAN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
