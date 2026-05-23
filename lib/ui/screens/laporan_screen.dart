import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/laporan_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LaporanProvider>(context, listen: false).fetchLaporan();
    });
  }

  String formatRupiah(double? number) {
    if (number == null) return "Rp 0";
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              // ignore: deprecated_member_use
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(amount),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Laporan Keuangan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005088),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<LaporanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                provider.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (provider.laporanData == null) {
            return const Center(child: Text("Belum ada data laporan"));
          }

          final ringkasan = provider.laporanData!['ringkasan_global'];

          return RefreshIndicator(
            onRefresh: () => provider.fetchLaporan(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Ringkasan Performa Bengkel",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005088),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildSummaryCard(
                  "Total Pendapatan (Omzet)",
                  ringkasan['total_pendapatan']?.toDouble(),
                  Colors.blue,
                  Icons.account_balance_wallet,
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  "Total HPP & Biaya Extra",
                  ringkasan['total_hpp']?.toDouble(),
                  Colors.red,
                  Icons.money_off,
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  "Total Laba Bersih",
                  ringkasan['total_margin']?.toDouble(),
                  Colors.green,
                  Icons.trending_up,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
