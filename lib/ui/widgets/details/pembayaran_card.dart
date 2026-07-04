import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/detail_pesanan_model.dart';
import '../../../utils/pdf_helper.dart';
import '../../../core/constants.dart'; // Tambahan untuk mengakses baseUrl

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
    double totalBiayaJasa = 0;
    double totalBiayaLainnya = 0;

    if (detail.biayaTambahans != null) {
      for (var biaya in detail.biayaTambahans) {
        if (biaya.kategori.toLowerCase() == 'jasa') {
          totalBiayaJasa += biaya.nominal;
        } else {
          totalBiayaLainnya += biaya.nominal;
        }
      }
    }

    double akumulasiPembayaran = 0;

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
              double akumulasiSebelumnya = akumulasiPembayaran;
              akumulasiPembayaran += p.jumlah;

              double sisaSaatIni = detail.hargaJual - akumulasiPembayaran;
              if (sisaSaatIni < 0) sisaSaatIni = 0;

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

                        // ==========================================
                        // TOMBOL LIHAT BUKTI BAYAR (Hanya tampil jika ada URL gambar)
                        // ==========================================
                        if (p.buktiBayar != null && p.buktiBayar!.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              // Hilangkan /v1 dari baseUrl jika ada, karena r.Static ada di root server
                              String host = AppConstants.baseUrl.replaceAll(
                                '/v1',
                                '',
                              );
                              String fullImageUrl = '$host${p.buktiBayar}';

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    "Bukti Transfer",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  content: InteractiveViewer(
                                    child: Image.network(
                                      fullImageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => const Text(
                                            "Gambar gagal dimuat dari server",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Tutup"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.image, color: Colors.green),
                            tooltip: "Lihat Bukti Bayar",
                          ),

                        // Tombol Cetak Kwitansi
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
                              totalTagihan: detail.hargaJual,
                              pembayaranSebelumnya: akumulasiSebelumnya,
                              sisaTagihan: sisaSaatIni,
                            );
                          },
                          icon: const Icon(Icons.print, color: Colors.grey),
                          tooltip: "Cetak Kwitansi",
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            buildInfoRow(
              "Total Terbayar",
              formatRupiah(detail.keuangan.totalTerbayar),
              isHighlight: true,
              color: Colors.blue,
            ),
            buildInfoRow(
              "Sisa Tagihan",
              detail.keuangan.sisaTagihan <= 0
                  ? "LUNAS"
                  : formatRupiah(detail.keuangan.sisaTagihan),
              isHighlight: true,
              color: detail.keuangan.sisaTagihan <= 0
                  ? Colors.green
                  : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
