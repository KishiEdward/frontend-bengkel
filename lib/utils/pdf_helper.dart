import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfHelper {
  static String formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(number);
  }

  // Fungsi untuk mencetak satu riwayat pembayaran menjadi Kwitansi
  static Future<void> cetakKwitansiPembayaran({
    required String namaKlien,
    required String noPesanan,
    required Map<String, dynamic> dataPembayaran,
  }) async {
    final pdf = pw.Document();

    String tipe = dataPembayaran['tipe'] ?? 'Pembayaran';
    double jumlah = dataPembayaran['jumlah']?.toDouble() ?? 0.0;
    String tgl = dataPembayaran['tgl'] != null ? dataPembayaran['tgl'].toString().substring(0, 10) : 'Tanggal Tidak Diketahui';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5, // Ukuran kertas A5 (cocok untuk kwitansi)
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text("BENGKEL BUBUT", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Center(
                  child: pw.Text("Jl. Pembangunan No. 123, Kota", style: const pw.TextStyle(fontSize: 12)),
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 16),
                
                pw.Center(
                  child: pw.Text("KWITANSI PEMBAYARAN", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                ),
                pw.SizedBox(height: 24),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("No. Referensi: INV-$noPesanan"),
                    pw.Text("Tanggal: $tgl"),
                  ]
                ),
                pw.SizedBox(height: 16),

                pw.Text("Telah terima dari : $namaKlien", style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text("Untuk Pembayaran: $tipe Proyek Jasa Bengkel", style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 24),
                
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("JUMLAH TERBILANG:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text(formatRupiah(jumlah), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ]
                  ),
                ),
                pw.SizedBox(height: 40),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("Penerima,"),
                        pw.SizedBox(height: 50),
                        pw.Text("( .......................... )"),
                      ]
                    )
                  ]
                )
              ],
            ),
          );
        },
      ),
    );

    // Langsung memunculkan preview PDF yang bisa di-print atau di-share
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Kwitansi_${namaKlien}_$tipe.pdf',
    );
  }
}