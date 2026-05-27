import 'package:flutter/material.dart';

import '../../../data/models/detail_pesanan_model.dart';

class InfoCustomerCard extends StatelessWidget {
  final DetailPesananModel detail;

  const InfoCustomerCard({super.key, required this.detail});

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
              "Informasi Pelanggan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const Divider(),

            buildInfoRow("Nama", detail.customer.nama),

            buildInfoRow("Status", detail.status),

            buildInfoRow("Tanggal Order", detail.tglOrder.substring(0, 10)),
          ],
        ),
      ),
    );
  }
}
