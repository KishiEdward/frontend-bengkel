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

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Catat Biaya Tambahan"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ketCtrl,
              decoration: const InputDecoration(labelText: "Keterangan"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nomCtrl,
              keyboardType: TextInputType.number,

              inputFormatters: [CurrencyInputFormatter()],

              decoration: const InputDecoration(labelText: "Nominal (Rp)"),
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
              if (ketCtrl.text.isEmpty || nomCtrl.text.isEmpty) {
                return;
              }

              Navigator.pop(context);

              double nominal = double.parse(nomCtrl.text.replaceAll('.', ''));

              bool sukses = await Provider.of<DetailPesananProvider>(
                context,
                listen: false,
              ).tambahBiayaTakTerduga(pesananId, ketCtrl.text, nominal);

              if (sukses && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Biaya berhasil dicatat"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
