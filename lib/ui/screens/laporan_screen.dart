import 'package:flutter/material.dart';
import 'package:front_bengkel/utils/pdf_helper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/laporan_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  // 1. ATUR DEFAULT FILTER KE WAKTU SAAT INI
  late String selectedMonth;
  late String selectedYear;

  final List<String> months = [
    'Semua',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
  ];
  final List<String> years = ['Semua', '2024', '2025', '2026', '2027'];

  @override
  void initState() {
    super.initState();
    selectedMonth = _normalizeFilterValue('Semua');
    selectedYear = _normalizeFilterValue('Semua');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LaporanProvider>(
        context,
        listen: false,
      ).fetchLaporan(bulan: selectedMonth, tahun: selectedYear);
    });
  }

  String _normalizeFilterValue(String? value) {
    if (value == null || value.trim().isEmpty) return 'Semua';
    final normalized = value.trim();
    return normalized.toLowerCase() == 'semua' ? 'Semua' : normalized;
  }

  String getMonthName(String monthNumber) {
    if (monthNumber == 'Semua') return 'Semua Bulan';
    const monthNames = {
      '01': 'Januari',
      '02': 'Februari',
      '03': 'Maret',
      '04': 'April',
      '05': 'Mei',
      '06': 'Juni',
      '07': 'Juli',
      '08': 'Agustus',
      '09': 'September',
      '10': 'Oktober',
      '11': 'November',
      '12': 'Desember',
    };
    return monthNames[monthNumber] ?? '';
  }

  String formatRupiah(double number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  // --- WIDGET HELPER UNTUK SECTION TITLE ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900, // Extra bold
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Laporan Keuangan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF005088),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 2. TOMBOL EKSPOR PDF DI APPBAR
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () async {
                // Ambil data ringkasan dari provider yang sedang aktif
                final provider = Provider.of<LaporanProvider>(
                  context,
                  listen: false,
                );
                final ringkasan = provider.laporanData?['ringkasan_global'];

                if (ringkasan != null) {
                  // Memanggil PdfHelper untuk membuat dan menampilkan PDF
                  await PdfHelper.cetakLaporanKeuangan(
                    periodeBulan: getMonthName(selectedMonth),
                    // Jika 'Semua', ubah jadi 'Semua Tahun', jika bukan biarkan angkanya
                    periodeTahun: selectedYear == 'Semua'
                        ? 'Semua Tahun'
                        : selectedYear,
                    ringkasan: ringkasan,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data laporan belum tersedia"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.picture_as_pdf,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                "Ekspor PDF",
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<LaporanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.laporanData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty &&
              provider.laporanData == null) {
            return Center(
              child: Text(
                provider.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final ringkasan = provider.laporanData?['ringkasan_global'] ?? {};

          // Variabel Ringkasan Performa
          double totalOmzet = (ringkasan['total_pendapatan'] ?? 0).toDouble();
          double totalHPP = (ringkasan['total_hpp'] ?? 0).toDouble();
          double labaBersih = (ringkasan['total_margin'] ?? 0).toDouble();

          // Kalkulasi Margin & Rata-rata
          int jumlahPesanan = (ringkasan['jumlah_pesanan'] ?? 0).toInt();
          double persenMargin = totalOmzet > 0
              ? (labaBersih / totalOmzet) * 100
              : 0;
          double avgPerPesanan = jumlahPesanan > 0
              ? totalOmzet / jumlahPesanan
              : 0;

          // Variabel Status Pembayaran
          double totalPiutang = (ringkasan['total_piutang'] ?? 0).toDouble();
          double uangMasukLunas =
              totalOmzet - totalPiutang; // Ini uang kas riil
          if (uangMasukLunas < 0) uangMasukLunas = 0;
          double persenKoleksi = totalOmzet > 0
              ? (uangMasukLunas / totalOmzet) * 100
              : 0;

          // Variabel Rincian Pengeluaran
          double rincianMaterial = (ringkasan['rincian_material'] ?? 0)
              .toDouble();
          double rincianJasa = (ringkasan['rincian_jasa'] ?? 0).toDouble();
          double rincianExtra = (ringkasan['rincian_extra'] ?? 0).toDouble();
          int countSelesai = (ringkasan['count_selesai'] ?? 0).toInt();
          int countMenungguPelunasan =
              (ringkasan['count_menunggu_pelunasan'] ?? 0).toInt();
          int countBatal = (ringkasan['count_batal'] ?? 0).toInt();
          int countWIP = (ringkasan['count_wip'] ?? 0).toInt();
          int countMenungguDP = (ringkasan['count_menunggu_dp'] ?? 0).toInt();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =================================
                // 1. FILTER WAKTU (Desain Minimalis)
                // =================================
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.grey),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<String>(
                        value: _normalizeFilterValue(selectedMonth),
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        items: months.map((String value) {
                          return DropdownMenuItem<String>(
                            value: _normalizeFilterValue(value),
                            child: Text(
                              getMonthName(value),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(
                            () => selectedMonth = _normalizeFilterValue(v),
                          );
                          provider.fetchLaporan(
                            bulan: selectedMonth,
                            tahun: selectedYear,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<String>(
                        value: _normalizeFilterValue(selectedYear),
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        items: years.map((String value) {
                          return DropdownMenuItem<String>(
                            value: _normalizeFilterValue(value),
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(
                            () => selectedYear = _normalizeFilterValue(v),
                          );
                          provider.fetchLaporan(
                            bulan: selectedMonth,
                            tahun: selectedYear,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(),
                  ),

                // =================================
                // 2. RINGKASAN PERFORMA
                // =================================
                _buildSectionTitle("Ringkasan Performa"),
                _buildMainCard(
                  title: "Total Nilai Pesanan (Omzet)",
                  amount: formatRupiah(totalOmzet),
                  icon: Icons.receipt_long,
                  color: Colors.blue.shade700,
                  backgroundColor: Colors.blue.shade50,
                  subtitle: "$jumlahPesanan pesanan",
                ),
                const SizedBox(height: 12),
                _buildMainCard(
                  title: "Total HPP & Biaya Extra",
                  amount: formatRupiah(totalHPP),
                  icon: Icons.trending_down,
                  color: Colors.red.shade700,
                  backgroundColor: Colors.red.shade50,
                ),
                const SizedBox(height: 12),
                _buildMainCard(
                  title: "Estimasi Laba Bersih",
                  amount: formatRupiah(labaBersih),
                  icon: Icons.trending_up,
                  color: Colors.green.shade700,
                  backgroundColor: Colors.green.shade50,
                  badgeText: "Margin ${persenMargin.toStringAsFixed(1)}%",
                ),
                const SizedBox(height: 32),

                // =================================
                // 3. STATUS PEMBAYARAN (ARUS KAS RIIL)
                // =================================
                _buildSectionTitle("Status Pembayaran"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        "Sudah dibayar (Lunas/DP Masuk)",
                        formatRupiah(uangMasukLunas),
                        color: Colors.green.shade700,
                        isBold: true,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        "Belum dilunasi (Piutang)",
                        formatRupiah(totalPiutang),
                        color: Colors.orange.shade800,
                        isBold: true,
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tingkat koleksi",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${persenKoleksi.toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: persenKoleksi / 100,
                        backgroundColor: Colors.orange.shade100,
                        color: Colors.green,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),

                      // Warning jika piutang > 50%
                      if (persenKoleksi < 50 && totalOmzet > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 20,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Piutang cukup tinggi (${(100 - persenKoleksi).toStringAsFixed(1)}% dari omzet). Pastikan jadwal penagihan pelunasan berjalan lancar.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // =================================
                // 3.5 STATUS PESANAN (KOTAK 2x2)
                // =================================
                _buildSectionTitle("Status Pesanan"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildStatusBox(
                            "Selesai & Lunas",
                            countSelesai,
                            Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _buildStatusBox(
                            "Menunggu Pelunasan",
                            countMenungguPelunasan,
                            Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatusBox(
                            "WIP (Dikerjakan)",
                            countWIP,
                            Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _buildStatusBox(
                            "Menunggu DP",
                            countMenungguDP,
                            Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatusBox("Batal", countBatal, Colors.red),
                          const SizedBox(width: 12),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // =================================
                // 4. METRIK TAMBAHAN
                // =================================
                _buildSectionTitle("Metrik Tambahan"),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "${persenMargin.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const Text(
                              "Margin Laba",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              NumberFormat.compactCurrency(
                                locale: 'id_ID',
                                symbol: 'Rp',
                                decimalDigits: 1,
                              ).format(avgPerPesanan),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              "Rata-rata / Pesanan",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // =================================
                // 5. RINCIAN OPERASIONAL
                // =================================
                _buildSectionTitle("Rincian Operasional"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        "Jumlah Pesanan",
                        "$jumlahPesanan Pesanan",
                        isBold: true,
                      ),
                      const Divider(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Rincian pengeluaran:",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        "• Belanja Material",
                        formatRupiah(rincianMaterial),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        "• Jasa CNC / Tukang",
                        formatRupiah(rincianJasa),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        "• Biaya Tambahan",
                        formatRupiah(rincianExtra),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper untuk Card Utama
  Widget _buildMainCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    String? subtitle,
    String? badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),

                if (subtitle != null || badgeText != null)
                  const SizedBox(height: 6),

                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Rincian Row
  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  // Helper untuk Kotak Status Pesanan
  Widget _buildStatusBox(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05), // Latar belakang sangat transparan
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
