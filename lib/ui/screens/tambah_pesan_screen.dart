import 'package:flutter/material.dart';
import 'package:front_bengkel/data/models/material_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../providers/pesanan_provider.dart';
import '../../providers/material_provider.dart';
import '../../data/models/customer_model.dart';

import '../widgets/tambah_pesanan/customer_section.dart';
import 'customer_screen.dart'; // Pastikan import ini sesuai dengan lokasi filemu

class MaterialInputItem {
  MaterialModel? selectedMaterial;
  TextEditingController qtyCtrl = TextEditingController();
  TextEditingController hargaCtrl = TextEditingController();
}

// CLASS BARU UNTUK JASA LAINNYA
class JasaLainInputItem {
  TextEditingController namaJasaCtrl = TextEditingController();
  TextEditingController hargaJasaCtrl = TextEditingController();
}

class TambahPesananScreen extends StatefulWidget {
  const TambahPesananScreen({super.key});

  @override
  State<TambahPesananScreen> createState() => _TambahPesananScreenState();
}

class _TambahPesananScreenState extends State<TambahPesananScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDeadline;

  // =========================
  // CUSTOMER
  // =========================
  CustomerModel? _selectedCustomer;

  // =========================
  // MATERIAL & JASA
  // =========================
  final List<MaterialInputItem> _listMaterial = [MaterialInputItem()];
  final List<JasaLainInputItem> _listJasaLain = []; // LIST JASA DINAMIS

  bool _pakaiJasaDesainer = false;
  bool _pakaijasaCNC = false;

  final _biayaDesainerCtrl = TextEditingController();
  final _biayaCNCCtrl = TextEditingController();

  // =========================
  // FINANCE
  // =========================
  double _totalHPP = 0.0;
  final _marginCtrl = TextEditingController(text: "50");
  final _hargaJualCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MaterialProvider>(context, listen: false).fetchMaterial();
    });
  }

  void _updateHPP() {
    double hpp = 0.0;

    for (var item in _listMaterial) {
      int qty = int.tryParse(item.qtyCtrl.text.replaceAll('.', '')) ?? 0;
      double harga =
          double.tryParse(item.hargaCtrl.text.replaceAll('.', '')) ?? 0.0;
      hpp += (qty * harga);
    }

    if (_pakaiJasaDesainer) {
      hpp +=
          double.tryParse(_biayaDesainerCtrl.text.replaceAll('.', '')) ?? 0.0;
    }
    if (_pakaijasaCNC) {
      hpp += double.tryParse(_biayaCNCCtrl.text.replaceAll('.', '')) ?? 0.0;
    }

    // HITUNG JASA LAIN KE HPP
    for (var jasa in _listJasaLain) {
      hpp +=
          double.tryParse(jasa.hargaJasaCtrl.text.replaceAll('.', '')) ?? 0.0;
    }

    setState(() {
      _totalHPP = hpp;
    });

    _updateHargaJualDariMargin();
  }

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

  void _updateMarginDariHargaJual() {
    if (_totalHPP == 0) return;
    double hargaJual =
        double.tryParse(_hargaJualCtrl.text.replaceAll('.', '')) ?? 0.0;
    double marginPersen = ((hargaJual - _totalHPP) / _totalHPP) * 100;
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
    }
  }

  // TAMBAH & HAPUS JASA LAIN
  void _tambahBarisJasaLain() {
    setState(() {
      _listJasaLain.add(JasaLainInputItem());
    });
  }

  void _hapusBarisJasaLain(int index) {
    setState(() {
      _listJasaLain.removeAt(index);
    });
    _updateHPP();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih customer terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<Map<String, dynamic>> payloadMaterials = _listMaterial.map((item) {
      int qty = int.tryParse(item.qtyCtrl.text.replaceAll('.', '')) ?? 0;
      double harga =
          double.tryParse(item.hargaCtrl.text.replaceAll('.', '')) ?? 0.0;
      return {
        "material_id": item.selectedMaterial?.id,
        "qty": qty,
        "harga_satuan": harga,
      };
    }).toList();

    // FORMAT PAYLOAD JASA LAIN UNTUK BACKEND
    List<Map<String, dynamic>> payloadJasaLain = _listJasaLain.map((item) {
      double harga =
          double.tryParse(item.hargaJasaCtrl.text.replaceAll('.', '')) ?? 0.0;
      return {"nama_jasa": item.namaJasaCtrl.text, "biaya": harga};
    }).toList();

    final payload = {
      "customer_id": _selectedCustomer!.id,
      "tgl_order": DateTime.now().toUtc().toIso8601String(),
      "tgl_deadline":
          (_selectedDeadline ?? DateTime.now().add(const Duration(days: 7)))
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
      "jasa_cnc": _pakaijasaCNC,
      "biaya_cnc": _pakaijasaCNC
          ? (double.tryParse(_biayaCNCCtrl.text.replaceAll('.', '')) ?? 0.0)
          : 0.0,
      "pesanan_material": payloadMaterials,
      "jasa_lainnya": payloadJasaLain, // DATA JASA LAIN MASUK SINI
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
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
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
            // 1. DATA PELANGGAN
            CustomerSection(
              onCustomerSelected: (customer) {
                _selectedCustomer = customer;
              },
            ),

            // SHORTCUT TAMBAH CUSTOMER
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text("Customer Baru?"),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF005088),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),

            // 2. TANGGAL DEADLINE
            _buildSectionTitle("2. Tanggal Deadline"),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(
                  _selectedDeadline == null
                      ? 'Pilih Tanggal Deadline'
                      : 'Deadline: ${DateFormat('dd-MM-yyyy').format(_selectedDeadline!)}',
                  style: TextStyle(
                    color: _selectedDeadline == null
                        ? Colors.grey.shade600
                        : Colors.black,
                  ),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate:
                        _selectedDeadline ??
                        DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null && picked != _selectedDeadline) {
                    setState(() {
                      _selectedDeadline = picked;
                    });
                  }
                },
              ),
            ),

            // 3. MATERIAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("3. Kebutuhan Material"),
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
                      Consumer<MaterialProvider>(
                        builder: (context, provider, child) {
                          return Autocomplete<MaterialModel>(
                            displayStringForOption: (MaterialModel option) =>
                                option.nama,
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              // Tampilkan semua jika kosong, jika tidak filter berdasarkan ketikan
                              if (textEditingValue.text == '') {
                                return provider.listMaterial;
                              }
                              return provider.listMaterial.where((
                                MaterialModel option,
                              ) {
                                return option.nama.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                );
                              });
                            },
                            onSelected: (MaterialModel selection) {
                              // Update state saat item di-klik dari hasil pencarian
                              setState(() {
                                _listMaterial[index].selectedMaterial =
                                    selection;
                                final format = NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: '',
                                  decimalDigits: 0,
                                );
                                _listMaterial[index].hargaCtrl.text = format
                                    .format(selection.hargaDefault);
                              });
                              _updateHPP();
                            },
                            fieldViewBuilder:
                                (
                                  context,
                                  textEditingController,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  // Menjaga teks tetap ada jika user sudah memilih sebelumnya
                                  if (_listMaterial[index].selectedMaterial !=
                                          null &&
                                      textEditingController.text.isEmpty) {
                                    textEditingController.text =
                                        _listMaterial[index]
                                            .selectedMaterial!
                                            .nama;
                                  }

                                  return TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      labelText: "Cari & Pilih Material",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(
                                        Icons.search,
                                      ), // Tambahan ikon search
                                    ),
                                    validator: (val) =>
                                        _listMaterial[index].selectedMaterial ==
                                            null
                                        ? "Pilih material"
                                        : null,
                                    // Hapus nilai jika user menghapus teks (membatalkan pilihan)
                                    onChanged: (val) {
                                      if (val.isEmpty) {
                                        setState(() {
                                          _listMaterial[index]
                                                  .selectedMaterial =
                                              null;
                                          _listMaterial[index].hargaCtrl
                                              .clear();
                                        });
                                        _updateHPP();
                                      }
                                    },
                                  );
                                },
                          );
                        },
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
                              onChanged: (val) => _updateHPP(),
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
                              onChanged: (val) => _updateHPP(),
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

            // 4. JASA TAMBAHAN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("4. Jasa Tambahan"),
                TextButton.icon(
                  onPressed: _tambahBarisJasaLain,
                  icon: const Icon(Icons.add, color: Color(0xFF11caa0)),
                  label: const Text(
                    "Jasa Lain",
                    style: TextStyle(color: Color(0xFF11caa0)),
                  ),
                ),
              ],
            ),

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
                        _updateHPP();
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
                        onChanged: (val) => _updateHPP(),
                        validator: (val) => (_pakaiJasaDesainer && val!.isEmpty)
                            ? "Wajib diisi"
                            : null,
                      ),
                    ),

                  const SizedBox(height: 16),

                  CheckboxListTile(
                    title: const Text(
                      "Gunakan Jasa CNC?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: _pakaijasaCNC,
                    activeColor: const Color(0xFF11caa0),
                    onChanged: (bool? value) {
                      setState(() {
                        _pakaijasaCNC = value ?? false;
                        if (!_pakaijasaCNC) _biayaCNCCtrl.clear();
                        _updateHPP();
                      });
                    },
                  ),
                  if (_pakaijasaCNC)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: TextFormField(
                        controller: _biayaCNCCtrl,
                        decoration: const InputDecoration(
                          labelText: "Biaya Jasa CNC (Rp)",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        onChanged: (val) => _updateHPP(),
                        validator: (val) => (_pakaijasaCNC && val!.isEmpty)
                            ? "Wajib diisi"
                            : null,
                      ),
                    ),
                ],
              ),
            ),

            // RENDER LIST JASA DINAMIS
            if (_listJasaLain.isNotEmpty) const SizedBox(height: 12),
            ...List.generate(_listJasaLain.length, (index) {
              return Card(
                elevation: 0,
                color: Colors.orange.shade50,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _listJasaLain[index].namaJasaCtrl,
                          decoration: const InputDecoration(
                            labelText: "Nama Jasa",
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (val) => val!.isEmpty ? "Isi" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _listJasaLain[index].hargaJasaCtrl,
                          decoration: const InputDecoration(
                            labelText: "Biaya (Rp)",
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [CurrencyInputFormatter()],
                          onChanged: (val) => _updateHPP(),
                          validator: (val) => val!.isEmpty ? "Isi" : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusBarisJasaLain(index),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // 5. PENETAPAN HARGA JUAL
            _buildSectionTitle("5. Penetapan Harga Jual"),
            Card(
              color: const Color(0xFF005088).withOpacity(0.05),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: const Color(0xFF005088).withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                            onChanged: (val) => _updateHargaJualDariMargin(),
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
                            onChanged: (val) => _updateMarginDariHargaJual(),
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
