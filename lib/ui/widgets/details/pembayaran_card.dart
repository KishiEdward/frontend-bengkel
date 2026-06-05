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
    // ==========================================
    // 1. COPY-PASTE LOGIKA DARI MARGIN CARD
    // ==========================================
    double totalBiayaJasa = 0;
    double totalBiayaLainnya = 0;

    // ignore: unnecessary_null_comparison
    if (detail.biayaTambahans != null) {
      for (var biaya in detail.biayaTambahans) {
        if (biaya.kategori.toLowerCase() == 'jasa') {
          totalBiayaJasa += biaya.nominal;
        } else {
          totalBiayaLainnya += biaya.nominal;
        }
      }
    }

    // Variabel untuk menghitung riwayat secara historis
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

            // ==========================================
            // 2. PERBAIKAN LOGIKA CETAK KWITANSI
            // ==========================================
            ...detail.pembayarans.map((p) {
              // Simpan nominal yang sudah dibayar SEBELUM baris ini
              double akumulasiSebelumnya = akumulasiPembayaran;

              // Baru setelah itu, tambahkan jumlah bayar saat ini ke dalam akumulasi
              akumulasiPembayaran += p.jumlah;

              // Hitung sisa tagihan persis pada saat pembayaran ini terjadi
              double sisaSaatIni = detail.hargaJual - akumulasiPembayaran;
              if (sisaSaatIni < 0)
                sisaSaatIni = 0; // Mencegah minus jika ada kelebihan bayar

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
                              totalTagihan: detail.hargaJual,
                              pembayaranSebelumnya:
                                  akumulasiSebelumnya, // <--- KIRIM DATA SEBELUMNYA KE SINI
                              sisaTagihan: sisaSaatIni,
                            );
                          },
                          icon: const Icon(Icons.print),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            buildInfoRow(
              "Total Tagihan",
              formatRupiah(detail.hargaJual),
              isHighlight: true,
            ),

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
