import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/detail_pesanan_provider.dart';
import '../../screens/detail_screen.dart';

class BiayaTambahanDialog {
  static Future<void> show(
    BuildContext context, {
    required int pesananId,
  }) async {
    final ketCtrl = TextEditingController();

    final nomCtrl = TextEditingController();

    // DEFAULT
    String kategori = "tambahan";

    await showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Catat Biaya"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    // =====================
                    // DROPDOWN KATEGORI
                    // =====================
                    DropdownButtonFormField<String>(
                      initialValue: kategori,

                      decoration: const InputDecoration(labelText: "Kategori"),

                      items: const [
                        DropdownMenuItem(
                          value: "jasa",

                          child: Text("Jasa Produksi"),
                        ),

                        DropdownMenuItem(
                          value: "tambahan",

                          child: Text("Biaya Tambahan"),
                        ),
                      ],

                      onChanged: (val) {
                        setState(() {
                          kategori = val!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // =====================
                    // KETERANGAN
                    // =====================
                    TextField(
                      controller: ketCtrl,

                      decoration: const InputDecoration(
                        labelText: "Keterangan",

                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =====================
                    // NOMINAL
                    // =====================
                    TextField(
                      controller: nomCtrl,

                      keyboardType: TextInputType.number,

                      inputFormatters: [CurrencyInputFormatter()],

                      decoration: const InputDecoration(
                        labelText: "Nominal (Rp)",

                        border: OutlineInputBorder(),
                      ),
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
                    if (ketCtrl.text.isEmpty || nomCtrl.text.isEmpty) {
                      return;
                    }

                    double nominal = double.parse(
                      nomCtrl.text.replaceAll('.', ''),
                    );

                    bool sukses =
                        await Provider.of<DetailPesananProvider>(
                          context,
                          listen: false,
                        ).tambahBiayaTakTerduga(
                          pesananId,

                          kategori,

                          ketCtrl.text,

                          nominal,
                        );

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          sukses
                              ? "Biaya berhasil dicatat"
                              : "Gagal mencatat biaya",
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
}
