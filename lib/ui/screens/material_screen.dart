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

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Material"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextField(
                  controller: namaCtrl,

                  decoration: const InputDecoration(labelText: "Nama Material"),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: satuanCtrl,

                  decoration: const InputDecoration(labelText: "Satuan"),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: hargaCtrl,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(labelText: "Harga Default"),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () async {
                if (namaCtrl.text.isEmpty ||
                    satuanCtrl.text.isEmpty ||
                    hargaCtrl.text.isEmpty) {
                  return;
                }

                double harga = double.tryParse(hargaCtrl.text) ?? 0;

                bool sukses =
                    await Provider.of<MaterialProvider>(
                      context,
                      listen: false,
                    ).tambahMaterial(
                      nama: namaCtrl.text,

                      satuan: satuanCtrl.text,

                      hargaDefault: harga,
                    );

                if (!mounted) return;

                // ignore: use_build_context_synchronously
                Navigator.pop(context);

                // ignore: use_build_context_synchronously
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
  }

  // =========================
  // FORMAT RUPIAH
  // =========================
  String formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
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

      body: Consumer<MaterialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.listMaterial.isEmpty) {
            return const Center(child: Text("Belum ada material"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: provider.listMaterial.length,

            itemBuilder: (context, index) {
              MaterialModel material = provider.listMaterial[index];

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
    );
  }
}
