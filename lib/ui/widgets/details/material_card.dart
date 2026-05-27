import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/detail_pesanan_model.dart';

class MaterialCard extends StatelessWidget {
  final DetailPesananModel detail;

  const MaterialCard({super.key, required this.detail});

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
              "Rincian Material",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const Divider(),

            ...detail.materials.map((m) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${m.material.nama} x${m.qty}"),
                    Text(formatRupiah(m.qty * m.hargaSatuan)),
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
