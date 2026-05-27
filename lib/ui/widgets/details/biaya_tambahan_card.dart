import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/detail_pesanan_model.dart';

class BiayaTambahanCard extends StatelessWidget {
  final DetailPesananModel detail;

  const BiayaTambahanCard({super.key, required this.detail});

  String formatRupiah(double number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Biaya Tambahan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const Divider(),

            ...detail.biayaTambahans.map((b) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(b.keterangan)),
                    Text(
                      formatRupiah(b.nominal),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
