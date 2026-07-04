import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfHelper {
  static String formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  // ==========================================
  // 1. FUNGSI CETAK KWITANSI PEMBAYARAN
  // ==========================================
  static Future<void> cetakKwitansiPembayaran({
    required String namaKlien,
    required String noPesanan,
    required Map<String, dynamic> dataPembayaran,
    required double totalTagihan,
    required double pembayaranSebelumnya,
    required double sisaTagihan,
  }) async {
    final pdf = pw.Document();

    String tipe = dataPembayaran['tipe'] ?? 'Pembayaran';
    double jumlahBayar = dataPembayaran['jumlah']?.toDouble() ?? 0.0;
    String tgl = dataPembayaran['tgl'] != null
        ? dataPembayaran['tgl'].toString().substring(0, 10)
        : 'Tanggal Tidak Diketahui';

    // Warna tema untuk desain modern (Biru tua & Abu-abu terang)
    final PdfColor primaryColor = PdfColor.fromHex('#1E3A8A');
    final PdfColor lightGrey = PdfColor.fromHex('#F3F4F6');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER MODERN ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "PUTRA TEKNIK MANDIRI",
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Jl. Pembangunan No. 123, Kota",
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      "KWITANSI",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 20),

              // --- INFO PESANAN & PELANGGAN ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn("Diterima Dari:", namaKlien, isBold: true),
                  _buildInfoColumn(
                    "No. Referensi:",
                    "INV-$noPesanan",
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    "Untuk Pembayaran:",
                    "$tipe Proyek Jasa Bengkel",
                  ),
                  _buildInfoColumn(
                    "Tanggal:",
                    tgl,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // --- KOTAK PERHITUNGAN BIAYA ---
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: lightGrey,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey200),
                ),
                child: pw.Column(
                  children: [
                    _buildCalculationRow(
                      "Total Keseluruhan Tagihan",
                      totalTagihan,
                    ),

                    // --- MUNCUL JIKA ADA DP/CICILAN SEBELUMNYA ---
                    if (pembayaranSebelumnya > 0) ...[
                      pw.SizedBox(height: 8),
                      _buildCalculationRow(
                        "Telah Dibayar Sebelumnya",
                        pembayaranSebelumnya,
                      ),
                    ],

                    pw.SizedBox(height: 8),
                    _buildCalculationRow(
                      "Pembayaran Saat Ini ($tipe)",
                      jumlahBayar,
                      textColor: primaryColor,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Divider(
                      color: PdfColors.grey400,
                      borderStyle: pw.BorderStyle.dashed,
                    ),
                    pw.SizedBox(height: 12),
                    _buildCalculationRow(
                      "Sisa Tagihan",
                      sisaTagihan,
                      isBold: true,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // --- FOOTER & TANDA TANGAN ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "Terima kasih atas kepercayaan Anda\nmenggunakan jasa kami.",
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "Penerima,",
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 50),
                      pw.Container(
                        width: 120,
                        child: pw.Divider(color: PdfColors.black),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Admin Bengkel",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Kwitansi_${namaKlien}_$tipe.pdf',
    );
  }

  // ==========================================
  // 2. FUNGSI CETAK LAPORAN KEUANGAN
  // ==========================================
  static Future<void> cetakLaporanKeuangan({
    required String periodeBulan,
    required String periodeTahun,
    required Map<String, dynamic> ringkasan,
  }) async {
    final pdf = pw.Document();

    // Ekstrak Data
    double totalOmzet = (ringkasan['total_pendapatan'] ?? 0).toDouble();
    double totalHPP = (ringkasan['total_hpp'] ?? 0).toDouble();
    double labaBersih = (ringkasan['total_margin'] ?? 0).toDouble();
    double totalPiutang = (ringkasan['total_piutang'] ?? 0).toDouble();
    double uangMasukLunas = totalOmzet - totalPiutang;
    if (uangMasukLunas < 0) uangMasukLunas = 0;

    int jumlahPesanan = (ringkasan['jumlah_pesanan'] ?? 0).toInt();
    double rincianMaterial = (ringkasan['rincian_material'] ?? 0).toDouble();
    double rincianJasa = (ringkasan['rincian_jasa'] ?? 0).toDouble();
    double rincianExtra = (ringkasan['rincian_extra'] ?? 0).toDouble();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Center(
                child: pw.Text(
                  "LAPORAN KEUANGAN BENGKEL BUBUT",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  "Periode: $periodeBulan $periodeTahun",
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // RINGKASAN PERFORMA
              pw.Text(
                "1. RINGKASAN PERFORMA",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
                cellStyle: const pw.TextStyle(fontSize: 11),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                data: <List<String>>[
                  ['Keterangan', 'Nominal'],
                  ['Total Nilai Pesanan (Omzet)', formatRupiah(totalOmzet)],
                  ['Total HPP & Biaya Extra', formatRupiah(totalHPP)],
                  ['Estimasi Laba Bersih', formatRupiah(labaBersih)],
                ],
              ),
              pw.SizedBox(height: 24),

              // STATUS PEMBAYARAN KAS
              pw.Text(
                "2. STATUS ARUS KAS (PEMBAYARAN)",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                cellStyle: const pw.TextStyle(fontSize: 11),
                data: <List<String>>[
                  [
                    'Sudah Dibayar (Lunas / DP Masuk)',
                    formatRupiah(uangMasukLunas),
                  ],
                  ['Belum Dilunasi (Piutang)', formatRupiah(totalPiutang)],
                ],
              ),
              pw.SizedBox(height: 24),

              // RINCIAN OPERASIONAL
              pw.Text(
                "3. RINCIAN OPERASIONAL PENGELUARAN",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Total Pesanan Dikerjakan: $jumlahPesanan Pesanan",
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                cellStyle: const pw.TextStyle(fontSize: 11),
                data: <List<String>>[
                  ['Belanja Material', formatRupiah(rincianMaterial)],
                  ['Jasa CNC / Tukang', formatRupiah(rincianJasa)],
                  ['Biaya Tambahan', formatRupiah(rincianExtra)],
                ],
              ),

              pw.Spacer(),

              // FOOTER & TTD
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "Dicetak pada: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Text(
                        "( Admin Bengkel )",
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Keuangan_Bengkel_${periodeBulan}_$periodeTahun.pdf',
    );
  }

  // ==========================================
  // WIDGET HELPER
  // ==========================================

  // Widget helper untuk merapikan teks informasi atas
  static pw.Widget _buildInfoColumn(
    String label,
    String value, {
    bool isBold = false,
    pw.CrossAxisAlignment crossAxisAlignment = pw.CrossAxisAlignment.start,
  }) {
    return pw.Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Widget helper untuk baris perhitungan
  static pw.Widget _buildCalculationRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 12,
    PdfColor textColor = PdfColors.black,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: textColor,
          ),
        ),
        pw.Text(
          formatRupiah(amount),
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: pw.FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
