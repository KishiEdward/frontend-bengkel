import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/material_provider.dart';
import '../../data/models/material_model.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MaterialProvider>(context, listen: false).fetchMaterial();
    });
  }

  // =========================
  // DIALOG TAMBAH MATERIAL
  // =========================
  void _showTambahDialog() {
    final namaCtrl = TextEditingController();
    final satuanCtrl = TextEditingController();
    final hargaCtrl = TextEditingController();

    List<MaterialModel> similarMaterials = [];

    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<MaterialProvider>(context, listen: false);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Material"),
              content: SingleChildScrollView(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: namaCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: "Nama Material",
                          ),
                          onChanged: (val) {
                            setStateDialog(() {
                              if (val.trim().isEmpty) {
                                similarMaterials = [];
                              } else {
                                // LOGIKA PENCARIAN AWALAN (startsWith)
                                similarMaterials = provider.listMaterial
                                    .where(
                                      (m) => m.nama.toLowerCase().startsWith(
                                        val.toLowerCase(),
                                      ),
                                    )
                                    .take(3)
                                    .toList();
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: satuanCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: "Satuan",
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: hargaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Harga Default",
                          ),
                        ),
                      ],
                    ),

                    // ==========================================
                    // FLOATING WARNING BOX
                    // ==========================================
                    if (similarMaterials.isNotEmpty)
                      Positioned(
                        top: 60, // Mengambang tepat di bawah TextField Nama
                        left: 0,
                        right: 0,
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Peringatan: Material serupa sudah ada!",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...similarMaterials.map(
                                  (m) => Text(
                                    "- ${m.nama} (${m.satuan})",
                                    // LOGIKA PEMBATAS PANJANG: Titik-titik
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (namaCtrl.text.isEmpty ||
                        satuanCtrl.text.isEmpty ||
                        hargaCtrl.text.isEmpty)
                      return;

                    double harga = double.tryParse(hargaCtrl.text) ?? 0;

                    bool sukses = await provider.tambahMaterial(
                      nama: namaCtrl.text,
                      satuan: satuanCtrl.text,
                      hargaDefault: harga,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          sukses
                              ? "Material berhasil ditambahkan"
                              : "Gagal menambah material",
                        ),
                        backgroundColor: sukses ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // [KODE BUILD DI BAWAH SINI SAMA PERSIS SEPERTI SEBELUMNYA]
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Master Material",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005088),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTambahDialog,
        backgroundColor: const Color(0xFF11caa0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari Material...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: Consumer<MaterialProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading)
                  return const Center(child: CircularProgressIndicator());
                if (provider.listMaterial.isEmpty)
                  return const Center(child: Text("Belum ada material"));

                final filteredList = provider.listMaterial.where((material) {
                  return material.nama.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredList.isEmpty)
                  return const Center(child: Text("Material tidak ditemukan"));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    MaterialModel material = filteredList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF005088),
                          child: Text(
                            material.nama[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          material.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Satuan: ${material.satuan}"),
                            Text(formatRupiah(material.hargaDefault)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
