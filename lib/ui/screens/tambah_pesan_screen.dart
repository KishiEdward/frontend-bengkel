import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pesanan_provider.dart';

// 1. Buat kelas bantuan untuk menyimpan controller tiap-tiap baris material
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
  final _hargaJualCtrl = TextEditingController();

  // variabel desainer
  bool _pakaiJasaDesainer = false;
  final _biayaDesainerCtrl = TextEditingController();

  // 2. Ubah dari controller tunggal menjadi List (kumpulan controller)
  // Default-nya kita sediakan 1 baris kosong saat halaman dibuka
  final List<MaterialInputItem> _listMaterial = [MaterialInputItem()];

  // Fungsi untuk menambah baris material baru
  void _tambahBarisMaterial() {
    setState(() {
      _listMaterial.add(MaterialInputItem());
    });
  }

  // Fungsi untuk menghapus baris material (minimal sisa 1)
  void _hapusBarisMaterial(int index) {
    if (_listMaterial.length > 1) {
      setState(() {
        _listMaterial.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimal harus ada 1 material!")),
      );
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // 3. Mapping List Controller menjadi bentuk JSON Array yang diminta Golang
    List<Map<String, dynamic>> payloadMaterials = _listMaterial.map((item) {
      int qty = int.tryParse(item.qtyCtrl.text) ?? 0;
      double harga = double.tryParse(item.hargaCtrl.text) ?? 0.0;
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
      "harga_jual": double.tryParse(_hargaJualCtrl.text) ?? 0.0,
      "status": "Menunggu DP",
      "jasa_desainer": _pakaiJasaDesainer,
      "biaya_desain": _pakaiJasaDesainer
          ? (double.tryParse(_biayaDesainerCtrl.text) ?? 0.0)
          : 0.0,
      "pesanan_material":
          payloadMaterials, // <-- Masukkan array material ke sini
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

            _buildSectionTitle("2. Detail Finansial"),
            TextFormField(
              controller: _hargaJualCtrl,
              decoration: const InputDecoration(
                labelText: "Harga Jual Proyek (Rp)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
            ),

            const SizedBox(height: 16),

            // 4. Bagian jasa desainer (opsional)
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
                    subtitle: const Text(
                      "Beri centang jika proyek ini butuh desain awal",
                    ),
                    value: _pakaiJasaDesainer,
                    activeColor: const Color(0xFF11caa0),
                    onChanged: (bool? value) {
                      setState(() {
                        _pakaiJasaDesainer = value ?? false;
                        if (!_pakaiJasaDesainer) {
                          _biayaDesainerCtrl
                              .clear(); // Bersihkan nominal jika batal dicentang
                        }
                      });
                    },
                  ),
                  // Munculkan input form HANYA jika dicentang
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
                        validator: (val) => _pakaiJasaDesainer && val!.isEmpty
                            ? "Biaya jasa wajib diisi"
                            : null,
                      ),
                    ),
                ],
              ),
            ),

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

            // 4. Looping untuk merender list material secara dinamis
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
                          if (_listMaterial.length >
                              1) // Tombol hapus muncul jika lebih dari 1
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
                          labelText:
                              "Nama Material (mis: Baja S45C, Oli, dll...)",
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
                                labelText: "Jumlah (Qty)",
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
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
