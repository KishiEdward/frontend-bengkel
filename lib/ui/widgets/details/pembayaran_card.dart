import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/detail_pesanan_model.dart';
import '../../../utils/pdf_helper.dart';

class PembayaranCard extends StatelessWidget {
  final DetailPesananModel detail;

  const PembayaranCard({super.key, required this.detail});

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const Divider(),

            if (detail.pembayarans.isEmpty) const Text("Belum ada pembayaran"),

            ...detail.pembayarans.map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text("${p.tipe}\n${p.tgl.substring(0, 10)}"),
                    ),

                    Row(
                      children: [
                        Text(
                          formatRupiah(p.jumlah),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            PdfHelper.cetakKwitansiPembayaran(
                              namaKlien: detail.customer.nama,
                              noPesanan: detail.id.toString(),
                              dataPembayaran: {
                                "tipe": p.tipe,
                                "jumlah": p.jumlah,
                                "tgl": p.tgl,
                              },
                            );
                          },
                          icon: const Icon(Icons.print),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            buildInfoRow(
              "Biaya Material",

              formatRupiah(detail.keuangan.totalBiayaMaterial),

              isHighlight: true,
            ),

            buildInfoRow(
              "Biaya Jasa",

              formatRupiah(detail.keuangan.totalBiayaJasa),

              isHighlight: true,

              color: Colors.orange,
            ),

            buildInfoRow(
              "Biaya Tambahan",

              formatRupiah(detail.keuangan.totalBiayaTambahan),

              isHighlight: true,

              color: Colors.red,
            ),

            buildInfoRow(
              "HPP Aktual",

              formatRupiah(detail.keuangan.hppAktual),

              isHighlight: true,

              color: Colors.deepOrange,
            ),

            buildInfoRow(
              "Margin Aktual",

              formatRupiah(detail.keuangan.marginAktual),

              isHighlight: true,

              color: detail.keuangan.marginAktual < 0
                  ? Colors.red
                  : Colors.green,
            ),

            const Divider(),

            const Divider(),

            buildInfoRow(
              "Total Terbayar",
              formatRupiah(detail.keuangan.totalTerbayar),
              isHighlight: true,
              color: Colors.blue,
            ),

            buildInfoRow(
              "Sisa Tagihan",
              formatRupiah(detail.keuangan.sisaTagihan),
              isHighlight: true,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
