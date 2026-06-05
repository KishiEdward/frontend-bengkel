import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/laporan_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String selectedMonth = 'Semua';
  String selectedYear = 'Semua';

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
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LaporanProvider>(
        context,
        listen: false,
      ).fetchLaporan(bulan: selectedMonth, tahun: selectedYear);
    });
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

          double totalOmzet = (ringkasan['total_pendapatan'] ?? 0).toDouble();
          double totalHPP = (ringkasan['total_hpp'] ?? 0).toDouble();
          double labaBersih = (ringkasan['total_margin'] ?? 0).toDouble();

          double totalPiutang = (ringkasan['total_piutang'] ?? 0).toDouble();
          int jumlahPesanan = (ringkasan['jumlah_pesanan'] ?? 0).toInt();

          double rincianMaterial = (ringkasan['rincian_material'] ?? 0)
              .toDouble();
          double rincianJasa = (ringkasan['rincian_jasa'] ?? 0).toDouble();
          double rincianExtra = (ringkasan['rincian_extra'] ?? 0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =================================
                // 1. BAGIAN FILTER WAKTU
                // =================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF005088),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Periode:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedMonth,
                          underline: const SizedBox(),
                          items: months.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                getMonthName(value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedMonth = newValue!;
                            });
                            provider.fetchLaporan(
                              bulan: selectedMonth,
                              tahun: selectedYear,
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 8),

                      DropdownButton<String>(
                        value: selectedYear,
                        underline: const SizedBox(),
                        items: years.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedYear = newValue!;
                          });
                          provider.fetchLaporan(
                            bulan: selectedMonth,
                            tahun: selectedYear,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (provider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: LinearProgressIndicator(),
                    ),
                  ),

                const Center(
                  child: Text(
                    "Ringkasan Performa Bengkel",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005088),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // =================================
                // 2. KARTU UTAMA (Omzet, HPP, Laba)
                // =================================
                _buildMainCard(
                  title: "Total Pendapatan (Omzet)",
                  amount: formatRupiah(totalOmzet),
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                  backgroundColor: Colors.blue.shade50,
                ),
                const SizedBox(height: 12),
                _buildMainCard(
                  title: "Total HPP & Biaya Extra",
                  amount: formatRupiah(totalHPP),
                  icon: Icons.money_off,
                  color: Colors.red,
                  backgroundColor: Colors.red.shade50,
                ),
                const SizedBox(height: 12),
                _buildMainCard(
                  title: "Total Laba Bersih",
                  amount: formatRupiah(labaBersih),
                  icon: labaBersih >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: labaBersih >= 0 ? Colors.green : Colors.red,
                  backgroundColor: labaBersih >= 0
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                ),

                const SizedBox(height: 24),
                const Text(
                  "Rincian Operasional",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005088),
                  ),
                ),
                const SizedBox(height: 16),

                // =================================
                // 3. KARTU RINCIAN TAMBAHAN
                // =================================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          "Jumlah Pesanan",
                          "$jumlahPesanan Pesanan",
                          isBold: true,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          "Total Piutang (Belum Lunas)",
                          formatRupiah(totalPiutang),
                          color: Colors.orange,
                          isBold: true,
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Rincian Pengeluaran:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          "• Belanja Material",
                          formatRupiah(rincianMaterial),
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow(
                          "• Jasa CNC / Tukang",
                          formatRupiah(rincianJasa),
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow(
                          "• Biaya Tambahan",
                          formatRupiah(rincianExtra),
                        ),
                      ],
                    ),
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

  Widget _buildMainCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =================================
  // FUNGSI INI YANG DIUBAH (Anti-Overflow)
  // =================================
  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dibungkus Expanded agar teks mengalah jika angka kepanjangan
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
        const SizedBox(width: 8), // Jarak pemisah antara teks dan angka
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
