import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../providers/pesanan_provider.dart';

class MaterialInputItem {
  TextEditingController namaCtrl = TextEditingController();
  TextEditingController qtyCtrl = TextEditingController();
  TextEditingController hargaCtrl = TextEditingController();
}

class TambahPesananScreen extends StatefulWidget {
  const TambahPesananScreen({super.key});

  @override
  State<TambahPesananScreen> createState() => _TambahPesananScreenState();
}

class _TambahPesananScreenState extends State<TambahPesananScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaCustomerCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _noTelpCtrl = TextEditingController();

  final List<MaterialInputItem> _listMaterial = [MaterialInputItem()];

  bool _pakaiJasaDesainer = false;
  final _biayaDesainerCtrl = TextEditingController();

  // Variabel Finansial Baru
  double _totalHPP = 0.0;
  final _marginCtrl = TextEditingController(text: "50"); // Default Margin 50%
  final _hargaJualCtrl = TextEditingController();

  // 1. Fungsi Menghitung Total HPP (Material + Desainer)
  void _updateHPP() {
    double hpp = 0.0;

    for (var item in _listMaterial) {
      int qty = int.tryParse(item.qtyCtrl.text.replaceAll('.', '')) ?? 0;
      double harga =
          double.tryParse(item.hargaCtrl.text.replaceAll('.', '')) ?? 0.0;
      hpp += (qty * harga);
    }

    if (_pakaiJasaDesainer) {
      double biayaDesain =
          double.tryParse(_biayaDesainerCtrl.text.replaceAll('.', '')) ?? 0.0;
      hpp += biayaDesain;
    }

    setState(() {
      _totalHPP = hpp;
    });

    // Setelah HPP diupdate, otomatis hitung ulang Harga Jual berdasarkan persentase Margin saat ini
    _updateHargaJualDariMargin();
  }

  // 2. Fungsi: Margin -> Harga Jual
  void _updateHargaJualDariMargin() {
    if (_totalHPP == 0) {
      _hargaJualCtrl.clear();
      return;
    }

    double marginPersen = double.tryParse(_marginCtrl.text) ?? 0.0;
    double hargaJual = _totalHPP + (_totalHPP * (marginPersen / 100));

    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    _hargaJualCtrl.text = format.format(hargaJual);
  }

  // 3. Fungsi: Harga Jual -> Margin (Untuk skenario Negosiasi)
  void _updateMarginDariHargaJual() {
    if (_totalHPP == 0) return;

    double hargaJual =
        double.tryParse(_hargaJualCtrl.text.replaceAll('.', '')) ?? 0.0;
    double marginPersen = ((hargaJual - _totalHPP) / _totalHPP) * 100;

    // Format agar tidak kepanjangan desimalnya (contoh: 45.5% atau 50%)
    _marginCtrl.text = marginPersen.toStringAsFixed(1).replaceAll('.0', '');
  }

  void _tambahBarisMaterial() {
    setState(() {
      _listMaterial.add(MaterialInputItem());
    });
  }

  void _hapusBarisMaterial(int index) {
    if (_listMaterial.length > 1) {
      setState(() {
        _listMaterial.removeAt(index);
      });
      _updateHPP();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimal harus ada 1 material!")),
      );
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    List<Map<String, dynamic>> payloadMaterials = _listMaterial.map((item) {
      int qty = int.tryParse(item.qtyCtrl.text.replaceAll('.', '')) ?? 0;
      double harga =
          double.tryParse(item.hargaCtrl.text.replaceAll('.', '')) ?? 0.0;
      return {
        "material": {"nama": item.namaCtrl.text, "qty": qty, "harga": harga},
        "qty": qty,
        "harga_satuan": harga,
      };
    }).toList();

    final payload = {
      "customer": {
        "nama": _namaCustomerCtrl.text,
        "alamat": _alamatCtrl.text,
        "no_telp": _noTelpCtrl.text,
      },
      "tgl_order": DateTime.now().toUtc().toIso8601String(),
      "tgl_deadline": DateTime.now()
          .add(const Duration(days: 7))
          .toUtc()
          .toIso8601String(),
      "harga_jual":
          double.tryParse(_hargaJualCtrl.text.replaceAll('.', '')) ?? 0.0,
      "status": "Menunggu DP",
      "jasa_desainer": _pakaiJasaDesainer,
      "biaya_desain": _pakaiJasaDesainer
          ? (double.tryParse(_biayaDesainerCtrl.text.replaceAll('.', '')) ??
                0.0)
          : 0.0,
      "pesanan_material": payloadMaterials,
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
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatRupiahLabel(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
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
            // ================= SECTION 1: PELANGGAN =================
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

            // ================= SECTION 2: MATERIAL =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("2. Kebutuhan Material"),
                TextButton.icon(
                  onPressed: _tambahBarisMaterial,
                  icon: const Icon(Icons.add_circle, color: Color(0xFF11caa0)),
                  label: const Text(
                    "Tambah Material",
                    style: TextStyle(color: Color(0xFF11caa0)),
                  ),
                ),
              ],
            ),
            ...List.generate(_listMaterial.length, (index) {
              return Card(
                color: Colors.blue[50],
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Material #${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (_listMaterial.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusBarisMaterial(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _listMaterial[index].namaCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nama Material",
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _listMaterial[index].qtyCtrl,
                              decoration: const InputDecoration(
                                labelText: "Qty",
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [CurrencyInputFormatter()],
                              onChanged: (val) =>
                                  _updateHPP(), // Update Realtime
                              validator: (val) => val!.isEmpty ? "Isi" : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _listMaterial[index].hargaCtrl,
                              decoration: const InputDecoration(
                                labelText: "Harga Satuan (Rp)",
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [CurrencyInputFormatter()],
                              onChanged: (val) =>
                                  _updateHPP(), // Update Realtime
                              validator: (val) =>
                                  val!.isEmpty ? "Wajib diisi" : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            // ================= SECTION 3: JASA DESAINER =================
            _buildSectionTitle("3. Jasa Tambahan"),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: _pakaiJasaDesainer
                      ? const Color(0xFF11caa0)
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text(
                      "Gunakan Jasa Desainer?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: _pakaiJasaDesainer,
                    activeColor: const Color(0xFF11caa0),
                    onChanged: (bool? value) {
                      setState(() {
                        _pakaiJasaDesainer = value ?? false;
                        if (!_pakaiJasaDesainer) _biayaDesainerCtrl.clear();
                        _updateHPP(); // Update Realtime
                      });
                    },
                  ),
                  if (_pakaiJasaDesainer)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: TextFormField(
                        controller: _biayaDesainerCtrl,
                        decoration: const InputDecoration(
                          labelText: "Biaya Jasa Desainer (Rp)",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        onChanged: (val) => _updateHPP(), // Update Realtime
                        validator: (val) => _pakaiJasaDesainer && val!.isEmpty
                            ? "Wajib diisi"
                            : null,
                      ),
                    ),
                ],
              ),
            ),

            // ================= SECTION 4: KALKULASI FINANSIAL =================
            _buildSectionTitle("4. Penetapan Harga Jual"),
            Card(
              // ignore: deprecated_member_use
              color: const Color(0xFF005088).withOpacity(0.05),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF005088).withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Tampilan HPP Realtime
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total HPP Aktual:",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          _formatRupiahLabel(_totalHPP),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32, thickness: 1.5),

                    // Input Margin vs Harga Jual
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _marginCtrl,
                            decoration: const InputDecoration(
                              labelText: "Margin (%)",
                              border: OutlineInputBorder(),
                              suffixText: "%",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) =>
                                _updateHargaJualDariMargin(), // Jika Margin diubah, update Harga Jual
                            validator: (val) => val!.isEmpty ? "Isi" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _hargaJualCtrl,
                            decoration: const InputDecoration(
                              labelText: "Harga Jual Final (Rp)",
                              border: OutlineInputBorder(),
                              prefixText: "Rp ",
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            onChanged: (val) =>
                                _updateMarginDariHargaJual(), // Jika Harga Jual diubah (nego), update Margin
                            validator: (val) =>
                                val!.isEmpty ? "Wajib diisi" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "*Ubah persentase margin atau edit langsung harga jual jika ada negosiasi dengan klien.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
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

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return newValue.copyWith(text: '');
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    String formatted = format.format(int.parse(numericOnly));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
