import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/detail_pesanan_model.dart';

class BiayaTambahanCard extends StatelessWidget {
  final DetailPesananModel detail;

  const BiayaTambahanCard({super.key, required this.detail});

  // =========================
  // FORMAT RUPIAH
  // =========================
  String formatRupiah(double number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    // =========================
    // FILTER BIAYA JASA
    // =========================
    final jasaList = detail.biayaTambahans.where((e) {
      String kategori = e.kategori.toLowerCase();

      String ket = e.keterangan.toLowerCase();

      // SUPPORT DATA LAMA
      if (ket.contains("designer") ||
          ket.contains("desainer") ||
          ket.contains("cnc")) {
        return true;
      }

      return kategori == "jasa";
    }).toList();

    // =========================
    // FILTER BIAYA TAMBAHAN
    // =========================
    final tambahanList = detail.biayaTambahans.where((e) {
      String kategori = e.kategori.toLowerCase();

      String ket = e.keterangan.toLowerCase();

      // KELUARKAN DATA JASA
      if (ket.contains("designer") ||
          ket.contains("desainer") ||
          ket.contains("cnc")) {
        return false;
      }

      return kategori != "jasa";
    }).toList();

    return Column(
      children: [
        // =====================
        // CARD BIAYA JASA
        // =====================
        if (jasaList.isNotEmpty)
          Card(
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Biaya Jasa",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const Divider(),

                  ...jasaList.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Expanded(child: Text(item.keterangan)),

                          Text(
                            formatRupiah(item.nominal),

                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

        if (jasaList.isNotEmpty && tambahanList.isNotEmpty)
          const SizedBox(height: 16),

        // =====================
        // CARD BIAYA TAMBAHAN
        // =====================
        if (tambahanList.isNotEmpty)
          Card(
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Biaya Tambahan",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const Divider(),

                  ...tambahanList.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Expanded(child: Text(item.keterangan)),

                          Text(
                            formatRupiah(item.nominal),

                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
