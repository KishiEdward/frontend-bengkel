// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/detail_pesanan_provider.dart';
import 'package:flutter/services.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
                color: isHighlight
                    ? (highlightColor ?? Colors.black)
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Pembayaran
  void _tampilDialogPembayaran(BuildContext context, int pesananId) {
    String tipePilihan = "DP";
    final nominalCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Input Pembayaran"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: tipePilihan,
                  items: ["DP", "Cicilan", "Lunas"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => tipePilihan = val!),
                  decoration: const InputDecoration(
                    labelText: "Tipe Pembayaran",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nominalCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: "Jumlah (Rp)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (nominalCtrl.text.isEmpty) return;
                  Navigator.pop(context);

                  double nominalBersih = double.parse(
                    nominalCtrl.text.replaceAll('.', ''),
                  );

                  bool sukses = await Provider.of<DetailPesananProvider>(
                    context,
                    listen: false,
                  ).catatPembayaran(pesananId, tipePilihan, nominalBersih);

                  if (sukses && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Uang masuk dicatat!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dialog Biaya Tambahan
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
                labelText: "Keterangan (mis: Mata bor x2)",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nomCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: const InputDecoration(
                labelText: "Total Nominal (Rp)",
              ),
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
              Navigator.pop(context);

              double nominalBersih = double.parse(
                nomCtrl.text.replaceAll('.', ''),
              );

              bool sukses = await Provider.of<DetailPesananProvider>(
                context,
                listen: false,
              ).tambahBiayaTakTerduga(pesananId, ketCtrl.text, nominalBersih);

              if (sukses && mounted) {
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

  // Dialog Ubah Status
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
          final customer = pesanan['customer'] ?? {};

          final List listMaterial =
              pesanan['pesanan_material'] ?? pesanan['PesananMaterial'] ?? [];
          final List listBiayaTambahan =
              pesanan['biaya_tambahan'] ?? pesanan['BiayaTambahan'] ?? [];
          // KODE BARU: Ambil list histori pembayaran masuk
          final List listPembayaran =
              pesanan['pembayaran'] ?? pesanan['Pembayaran'] ?? [];

          // Kalkulasi Persentase Margin
          double marginBersih = keuangan['margin_aktual']?.toDouble() ?? 0;
          double hppAktual = keuangan['hpp_aktual']?.toDouble() ?? 0;
          double persenMargin = hppAktual > 0
              ? (marginBersih / hppAktual) * 100
              : 0.0;
          String textMarginBersih =
              "${formatRupiah(marginBersih)} (${persenMargin.toStringAsFixed(1)}%)";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. KARTU INFO CUSTOMER
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

                // 2. KARTU RINCIAN MATERIAL
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
                          "Rincian Material & Jasa",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005088),
                          ),
                        ),
                        const Divider(),
                        if (listMaterial.isEmpty)
                          const Text(
                            "Tidak ada data material",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ...listMaterial.map((m) {
                          String namaMaterial = m['material'] != null
                              ? m['material']['nama']
                              : (m['nama_material'] ?? 'Material');
                          int qty = m['qty'] ?? 0;
                          double hargaSatuan =
                              m['harga_satuan']?.toDouble() ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "$namaMaterial (x$qty)",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                Text(
                                  formatRupiah(qty * hargaSatuan),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. KARTU RINCIAN BIAYA TAMBAHAN
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
                          "Biaya Tambahan (Extra)",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005088),
                          ),
                        ),
                        const Divider(),
                        if (listBiayaTambahan.isEmpty)
                          const Text(
                            "Belum ada pengeluaran tambahan",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ...listBiayaTambahan.map((b) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    b['keterangan'] ?? 'Pengeluaran',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                Text(
                                  formatRupiah(b['nominal']?.toDouble()),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. KARTU KALKULASI MARGIN
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
                          "Total Material",
                          "- ${formatRupiah(keuangan['total_biaya_material']?.toDouble())}",
                          isHighlight: true,
                          highlightColor: Colors.red,
                        ),
                        _buildInfoRow(
                          "Total Tambahan",
                          "- ${formatRupiah(keuangan['total_biaya_tambahan']?.toDouble())}",
                          isHighlight: true,
                          highlightColor: Colors.red,
                        ),
                        const Divider(thickness: 2),
                        _buildInfoRow(
                          "HPP Aktual",
                          formatRupiah(hppAktual),
                          isHighlight: true,
                        ),
                        _buildInfoRow(
                          "Margin Bersih",
                          textMarginBersih,
                          isHighlight: true,
                          highlightColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. KARTU PEMBAYARAN (SEKARANG DENGAN HISTORI RINCIAN)
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
                          "Status & Riwayat Tagihan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005088),
                          ),
                        ),
                        const Divider(),

                        // KODE UPDATE: Menampilkan baris histori per transaksi cicilan/DP
                        if (listPembayaran.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              "Belum ada catatan uang masuk",
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ...listPembayaran.map((p) {
                          String tipe = p['tipe'] ?? 'Bayar';
                          double jumlah = p['jumlah']?.toDouble() ?? 0;
                          String tgl = p['tgl'] != null
                              ? p['tgl'].toString().substring(0, 10)
                              : '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Uang Masuk ($tipe) - $tgl",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  formatRupiah(jumlah),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const Divider(thickness: 1.5),
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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.payments),
                  label: const Text(
                    "Catat Pembayaran",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () =>
                      _tampilDialogPembayaran(context, pesanan['ID']),
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

// FORMATTER RIBUAN
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return newValue.copyWith(text: '');
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    String formatted = format.format(int.parse(numericOnly));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
