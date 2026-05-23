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

  // Dialog untuk Catat Biaya Tambahan
  void _tampilDialogBiayaTambahan(BuildContext context, int pesananId) {
    final ketCtrl = TextEditingController();
    final nomCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Catat Biaya Tambahan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ketCtrl,
              decoration: const InputDecoration(
                labelText: "Keterangan (Mata bor patah, dll)",
              ),
            ),
            TextField(
              controller: nomCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Nominal (Rp)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ketCtrl.text.isEmpty || nomCtrl.text.isEmpty) return;
              Navigator.pop(context); // Tutup dialog

              bool sukses =
                  await Provider.of<DetailPesananProvider>(
                    context,
                    listen: false,
                  ).tambahBiayaTakTerduga(
                    pesananId,
                    ketCtrl.text,
                    double.parse(nomCtrl.text),
                  );

              if (sukses && mounted) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Biaya dicatat! Margin diperbarui."),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // Dialog untuk Ubah Status
  void _tampilDialogUbahStatus(
    BuildContext context,
    int pesananId,
    String statusSaatIni,
  ) {
    String statusPilihan = statusSaatIni;
    final listStatus = ["Menunggu DP", "WIP", "Menunggu Pelunasan", "Selesai"];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Ubah Status Proyek"),
            content: DropdownButtonFormField<String>(
              initialValue: listStatus.contains(statusSaatIni)
                  ? statusSaatIni
                  : "Menunggu DP",
              items: listStatus
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => statusPilihan = val!),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Provider.of<DetailPesananProvider>(
                    context,
                    listen: false,
                  ).ubahStatusPesanan(pesananId, statusPilihan);
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
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
                const SizedBox(height: 24),

                // TOMBOL AKSI
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text("Ubah Status"),
                        onPressed: () => _tampilDialogUbahStatus(
                          context,
                          pesanan['ID'],
                          pesanan['status'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.money_off),
                        label: const Text("+ Biaya Extra"),
                        onPressed: () =>
                            _tampilDialogBiayaTambahan(context, pesanan['ID']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
