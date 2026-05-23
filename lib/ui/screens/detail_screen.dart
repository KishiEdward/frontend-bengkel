import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/detail_pesanan_provider.dart';

class DetailScreen extends StatefulWidget {
  final int pesananId;

  const DetailScreen({super.key, required this.pesananId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetailPesananProvider>(
        context,
        listen: false,
      ).fetchDetailPesanan(widget.pesananId);
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

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlight = false,
    Color? highlightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
              color: isHighlight
                  ? (highlightColor ?? Colors.black)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005088),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<DetailPesananProvider>(
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
          if (provider.detailData == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final pesanan = provider.detailData!['pesanan'];
          final keuangan = provider.detailData!['keuangan'];
          final customer = pesanan['customer'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // KARTU INFO CUSTOMER
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informasi Pelanggan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005088),
                          ),
                        ),
                        const Divider(),
                        _buildInfoRow("Nama", customer['nama'] ?? '-'),
                        _buildInfoRow(
                          "Status",
                          pesanan['status'] ?? '-',
                          isHighlight: true,
                          highlightColor: Colors.orange,
                        ),
                        _buildInfoRow(
                          "Tgl Order",
                          pesanan['tgl_order'] != null
                              ? pesanan['tgl_order'].toString().substring(0, 10)
                              : '-',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // KARTU KALKULASI MARGIN (Jantung Skripsi)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kalkulasi Margin Dinamis",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005088),
                          ),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          "Harga Jual",
                          formatRupiah(pesanan['harga_jual']?.toDouble()),
                        ),
                        _buildInfoRow(
                          "Biaya Material",
                          "- ${formatRupiah(keuangan['total_biaya_material']?.toDouble())}",
                          isHighlight: true,
                          highlightColor: Colors.red,
                        ),
                        _buildInfoRow(
                          "Biaya Tambahan",
                          "- ${formatRupiah(keuangan['total_biaya_tambahan']?.toDouble())}",
                          isHighlight: true,
                          highlightColor: Colors.red,
                        ),
                        const Divider(thickness: 2),
                        _buildInfoRow(
                          "HPP Aktual",
                          formatRupiah(keuangan['hpp_aktual']?.toDouble()),
                          isHighlight: true,
                        ),
                        _buildInfoRow(
                          "Margin Bersih",
                          formatRupiah(keuangan['margin_aktual']?.toDouble()),
                          isHighlight: true,
                          highlightColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // KARTU PEMBAYARAN
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Status Tagihan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005088),
                          ),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          "Total Terbayar",
                          formatRupiah(keuangan['total_terbayar']?.toDouble()),
                          isHighlight: true,
                          highlightColor: Colors.blue,
                        ),
                        _buildInfoRow(
                          "Sisa Tagihan",
                          formatRupiah(keuangan['sisa_tagihan']?.toDouble()),
                          isHighlight: true,
                          highlightColor: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
