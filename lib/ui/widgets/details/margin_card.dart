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
          Text(
            label,
            style: TextStyle(color: isHighlight ? Colors.black87 : Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.black,
              fontSize: isHighlight ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalBiayaJasa = 0;
    double totalBiayaLainnya = 0;

    if (detail.biayaTambahans != null) {
      for (var biaya in detail.biayaTambahans) {
        String kategori = (biaya.kategori ?? "").toString().toLowerCase();
        String ket = (biaya.keterangan ?? "").toString().toLowerCase();
        bool isJasa =
            kategori == "jasa" ||
            ket.contains("jasa") ||
            ket.contains("designer") ||
            ket.contains("desainer") ||
            ket.contains("cnc");

        if (isJasa) {
          totalBiayaJasa += biaya.nominal;
        } else {
          totalBiayaLainnya += biaya.nominal;
        }
      }
    }

    // Kalkulasi Manual
    double manualHpp =
        detail.keuangan.totalBiayaMaterial + totalBiayaJasa + totalBiayaLainnya;
    double manualMargin = detail.hargaJual - manualHpp;
    double persen = manualHpp > 0 ? (manualMargin / manualHpp) * 100 : 0;

    // ==========================================
    // LOGIKA WARNA MARGIN DINAMIS
    // ==========================================
    Color marginColor;
    if (manualMargin > 0) {
      marginColor = Colors.green; // Untung
    } else if (manualMargin < 0) {
      marginColor = Colors.red; // Rugi / Boncos
    } else {
      marginColor = Colors.orange.shade700; // Balik Modal (Break Even)
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kalkulasi Keuangan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),

            // TAMPILAN DETAIL YANG BISA DIBUKA-TUTUP (Logisnya ditaruh di atas HPP)
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  "Lihat Rincian Biaya (HPP)",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  buildInfoRow(
                    "Biaya Material",
                    "+ ${formatRupiah(detail.keuangan.totalBiayaMaterial)}",
                    color: Colors.grey.shade700,
                  ),
                  buildInfoRow(
                    "Biaya Jasa",
                    "+ ${formatRupiah(totalBiayaJasa)}",
                    color: Colors.grey.shade700,
                  ),
                  buildInfoRow(
                    "Biaya Tambahan",
                    "+ ${formatRupiah(totalBiayaLainnya)}",
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
            const Divider(),

            // TAMPILAN RINGKAS DI BAWAH (HPP + Margin = Harga Jual)
            buildInfoRow(
              "HPP Aktual",
              formatRupiah(manualHpp),
              isHighlight: true,
              color: Colors.orange.shade700,
            ),

            // Margin Bersih dengan Warna Dinamis
            buildInfoRow(
              "Margin Bersih",
              "${formatRupiah(manualMargin)}  (${persen.toStringAsFixed(1)}%)",
              isHighlight: true,
              color: marginColor,
            ),

            const SizedBox(height: 8),

            // Harga Jual (Disorot pakai warna biru/hitam agar membedakan hasil akhir)
            buildInfoRow(
              "Harga Jual (Total)",
              formatRupiah(detail.hargaJual),
              isHighlight: true,
              color: Colors.blue.shade800,
            ),
          ],
        ),
      ),
    );
  }
}
