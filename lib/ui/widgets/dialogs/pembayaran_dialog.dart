import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/detail_pesanan_provider.dart';
import '../../screens/detail_screen.dart';

class PembayaranDialog {
  static Future<void> show(
    BuildContext context, {
    required int pesananId,
  }) async {
    String tipePilihan = "DP";

    final nominalCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Input Pembayaran"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: tipePilihan,

                  items: ["DP", "Cicilan", "Lunas"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),

                  onChanged: (val) {
                    setState(() {
                      tipePilihan = val!;
                    });
                  },

                  decoration: const InputDecoration(
                    labelText: "Tipe Pembayaran",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: nominalCtrl,
                  keyboardType: TextInputType.number,

                  inputFormatters: [CurrencyInputFormatter()],

                  decoration: const InputDecoration(
                    labelText: "Jumlah (Rp)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
                  if (nominalCtrl.text.isEmpty) {
                    return;
                  }

                  Navigator.pop(context);

                  double nominal = double.parse(
                    nominalCtrl.text.replaceAll('.', ''),
                  );

                  bool sukses = await Provider.of<DetailPesananProvider>(
                    context,
                    listen: false,
                  ).catatPembayaran(pesananId, tipePilihan, nominal);

                  if (sukses && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pembayaran berhasil dicatat"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }
}
