import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/detail_pesanan_model.dart';

class MarginCard extends StatelessWidget {
  final DetailPesananModel detail;

  const MarginCard({super.key, required this.detail});

  String formatRupiah(double number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  Widget buildInfoRow(
    String label,
    String value, {
    bool isHighlight = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // 1. PISAHKAN BIAYA JASA DAN TAMBAHAN LAINNYA
    // ==========================================
    double totalBiayaJasa = 0;
    double totalBiayaLainnya = 0;

    // Catatan: Pastikan `biayaTambahan` adalah nama properti list
    // biaya tambahan yang ada di dalam class DetailPesananModel milikmu.
    // Jika namanya berbeda (misal: listBiayaTambahan), silakan disesuaikan.
    // ignore: unnecessary_null_comparison
    if (detail.biayaTambahans != null) {
      for (var biaya in detail.biayaTambahans) {
        // Gunakan toLowerCase() agar pencarian mengabaikan huruf besar/kecil
        if (biaya.kategori.toLowerCase() == 'jasa') {
          totalBiayaJasa += biaya.nominal;
        } else {
          totalBiayaLainnya += biaya.nominal;
        }
      }
    }

    // ==========================================
    // 2. AMBIL HPP & MARGIN DARI BACKEND
    // ==========================================
    // Kita tetap bisa menggunakan perhitungan HPP dan Margin dari backend
    // karena total akhirnya (Material + All Tambahan) tetap sama.
    double margin = detail.keuangan.marginAktual;
    double hpp = detail.keuangan.hppAktual;
    double persen = hpp > 0 ? (margin / hpp) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kalkulasi Margin",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),

            buildInfoRow("Harga Jual", formatRupiah(detail.hargaJual)),

            buildInfoRow(
              "Biaya Material",
              "- ${formatRupiah(detail.keuangan.totalBiayaMaterial)}",
              color: Colors.red,
            ),

            // ==============================================
            // BARIS BARU: Tampilkan Biaya Jasa terpisah
            // ==============================================
            buildInfoRow(
              "Biaya Jasa",
              "- ${formatRupiah(totalBiayaJasa)}",
              color: Colors.red,
            ),

            // ==============================================
            // UPDATE: Tampilkan sisa Biaya Tambahan (Non-Jasa)
            // ==============================================
            buildInfoRow(
              "Biaya Tambahan",
              "- ${formatRupiah(totalBiayaLainnya)}",
              color: Colors.red,
            ),

            const Divider(),

            buildInfoRow("HPP Aktual", formatRupiah(hpp), isHighlight: true),

            buildInfoRow(
              "Margin Bersih",
              "${formatRupiah(margin)} (${persen.toStringAsFixed(1)}%)",
              isHighlight: true,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
